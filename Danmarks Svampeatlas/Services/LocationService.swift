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
            default: return nil
            }
        }
        
        var errorDescription: String {
            switch self {
            case .badAccuracy:
                return "Det var ikke muligt at finde din lokation med en tilstrækkelig sikkerhed."
            case .permissionDenied:
                return "Du har afvist at appen skal kunne tilgå din GPS lokation, hvilket den skal kunne for at vise dig den her data."
            case .networkError:
                return "Det lader til at der skete en netværks fejl med din telefons GPS-komponent."
            case .unknown:
                return "Der skete en ukendt fejl i forsøget på at finde din GPS lokation."
            case .permissionsUndetermined:
                return "For at vise dig den her data, skal appen kunne finde ud af hvor du er."
            }
        }
        
        var errorTitle: String {
            switch self {
            case .permissionDenied:
                return "Manglende tilladelse"
            case .badAccuracy:
                return "Utilstrækelig nøjagtighed"
            case .networkError:
                return "Netværksfejl"
            case .unknown:
                return "Ukendt fejl"
            case .permissionsUndetermined:
                return "Hvor er du henne?"
            }
        }
        
        case permissionDenied
        case permissionsUndetermined
        case badAccuracy
        case networkError
        case unknown
    }
    
    private var locationManager: CLLocationManager?
    private var state: State = .stopped
    
    weak var delegate: LocationManagerDelegate? = nil
    private var previousAccuracy: Double = 0.0
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
            locationManager?.startUpdatingLocation()
            state = .locating
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
                self?.stopServiceAndSendLocation()
            }
        }
    }
    
    private func stopServiceAndSendLocation() {
        locationManager?.stopUpdatingHeading()
        state = .stopped
        
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
    
    private func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0, location.timestamp.timeIntervalSinceNow < 5 else {return}
        
        latestLocation = location
        
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            stopServiceAndSendLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = CLError.Code.init(rawValue: (error as NSError).code) {
            switch error {
            case .network: delegate?.locationInaccessible(error: .networkError)
            default: delegate?.locationInaccessible(error: .unknown)
            }
        }
    }
    
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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


