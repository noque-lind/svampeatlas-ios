//
//  LocationService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit

protocol LocationManagerDelegate: class {
    func locationInaccessible(error: LocationManager.LocationManagerError)
    func locationRetrieved(location: CLLocation)
}

class LocationManager: NSObject {
    
    enum State {
        case locating
        case stopped
    }
    
    
    enum LocationManagerError: AppError {
        
        var recoveryAction: RecoveryAction? {
            switch self {
            case .permissionDenied:
                return .openSettings
            case .permissionsUndetermined:
                return .activate
            default: return .tryAgain
            }
        }
        
        var errorDescription: String {
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
        
        var errorTitle: String {
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
    
    private var locationManager: CLLocationManager?
    private var state: State = .stopped {
        didSet {
            switch state {
            case .locating: locationManager?.startUpdatingLocation()
            case .stopped: locationManager?.stopUpdatingLocation()
            }
        }
    }
    
    weak var delegate: LocationManagerDelegate? = nil
    private var latestLocation: CLLocation?
    
    var permissionsNotDetermined: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return true
        default:
            return false
        }
    }
    
    func start() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.activityType = CLActivityType.other
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
    }
    
    private func startUpdatingLocation() {
        if state == .stopped {
            state = .locating
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
                if self?.state == State.locating {
                  self?.stopServiceAndSendLocation()
                } else {
                  self?.locationManager = nil
                }
            }
        }
    }
    
    private func stopServiceAndSendLocation() {
        guard state != .stopped else {return}
        state = .stopped
        locationManager = nil
        
        
        DispatchQueue.main.async {
            if let location = self.latestLocation {
                self.delegate?.locationRetrieved(location: location)
                self.latestLocation = nil
            } else {
                self.delegate?.locationInaccessible(error: .badAccuracy)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0, location.timestamp.timeIntervalSinceNow > -5  else {return}
                latestLocation = location
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            stopServiceAndSendLocation()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = CLError.Code.init(rawValue: (error as NSError).code) {
            state = .stopped
            switch error {
            case .network: delegate?.locationInaccessible(error: .networkError)
            default: delegate?.locationInaccessible(error: .unknown)
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
            delegate?.locationInaccessible(error: .permissionDenied)
        }
    }
}


