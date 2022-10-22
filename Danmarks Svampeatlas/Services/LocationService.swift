//
//  LocationService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import MapKit
import LogRocket

protocol LocationManagerDelegate: class {
    func locationInaccessible(error: LocationManager.LocationManagerError)
    func locationManagerIsLocating()
    func locationRetrieved(location: CLLocation)
}

class LocationManager: NSObject {
    
    enum Accuracy {
        case high
        case low
        
        var value: CLLocationAccuracy {
            switch self {
            case .high: return kCLLocationAccuracyHundredMeters
            case .low: return kCLLocationAccuracyThreeKilometers
            }
        }
    }
    
    enum State: Equatable {
        case stopped
        case locating
        case foundLocation(location: CLLocation)
        case error(error: LocationManagerError)
    }
    
    enum LocationManagerError: AppError, ELError {
        var recoveryAction: RecoveryAction? {
            switch self {
            case .permissionDenied:
                return .openSettings
            case .permissionsUndetermined:
                return .activate
            default: return .tryAgain
            }
        }
        
        var message: String {
            switch self {
            case .badAccuracy:
                return NSLocalizedString("locationManagerError_badAccuracy_message", comment: "")
            case .permissionDenied:
                return NSLocalizedString("locationManagerError_permissionDenied_message", comment: "")
            case .networkError:
                return NSLocalizedString("locationManagerError_networkError_message", comment: "")
            case .unknown:
                return NSLocalizedString("locationManagerError_unknown_message", comment: "")
            case .permissionsUndetermined:
                return NSLocalizedString("locationManagerError_permissionsUndetermined_message", comment: "")
            }
        }
        
        var title: String {
            switch self {
            case .permissionDenied:
                return NSLocalizedString("locationManagerError_permissionDenied_title", comment: "")
            case .badAccuracy:
                return NSLocalizedString("locationManagerError_badAccuracy_title", comment: "")
            case .networkError:
                return NSLocalizedString("locationManagerError_networkError_title", comment: "")
            case .unknown:
                return NSLocalizedString("locationManagerError_unknown_title", comment: "")
            case .permissionsUndetermined:
                return NSLocalizedString("locationManagerError_permissionsUndetermined_title", comment: "")
            }
        }
        
        case permissionDenied
        case permissionsUndetermined
        case badAccuracy
        case networkError
        case unknown
    }
    
    private let accuracy: Accuracy
    private var locationManager: CLLocationManager?
    let state: ELListener<State> = ELListener(State.stopped)
    private var latestLocation: CLLocation?
    
    var permissionsNotDetermined: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return true

        default:
            return false
        }
    }
    
    init(accuracy: Accuracy = .high) {
        self.accuracy = accuracy
    }
    
    func start() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.activityType = CLActivityType.other
        switch accuracy {
        case .high: locationManager?.desiredAccuracy = 65
        case .low: locationManager?.desiredAccuracy = accuracy.value
        }
        if #available(iOS 14.0, *) {
            if locationManager?.authorizationStatus == .denied || locationManager?.authorizationStatus == .restricted {
                state.set(.error(error: .permissionDenied))
            } else if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
                state.set(.error(error: .permissionDenied))
            } else {
                locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    private func startUpdatingLocation() {
        state.set(State.locating)
        locationManager?.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            if self?.state.value == State.locating {
              self?.stopServiceAndSendLocation()
            } else {
              self?.locationManager = nil
            }
        }
    }
    
    private func stopServiceAndSendLocation() {
        switch state.value {
        case .foundLocation, .stopped, .error:
            return
        case .locating:
            DispatchQueue.main.async {
                if let location = self.latestLocation, location.horizontalAccuracy <=  self.accuracy.value {
                    self.state.set(.foundLocation(location: location))
                    self.latestLocation = nil
                } else {
                    self.state.set(.error(error: .badAccuracy))
                }
            }
        }
        self.locationManager = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else {return}
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            
        }
        
        if accuracy == .high && location.timestamp.timeIntervalSinceNow > -2 {
            latestLocation = location
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            stopServiceAndSendLocation()
        }
        } else if accuracy == .low {
            latestLocation = location
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            stopServiceAndSendLocation()
        }
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.error(message: error.localizedDescription)
        if let error = CLError.Code.init(rawValue: (error as NSError).code) {
            switch error {
            case .network:
                state.set(.error(error: .networkError))
            default: state.set(.error(error: .unknown))
            }
        }
    }
    
   internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            state.set(.error(error: .permissionDenied))
        @unknown default:
            state.set(.error(error: .permissionsUndetermined))
        }
    }
}
