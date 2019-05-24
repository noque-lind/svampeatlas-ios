//
//  LocationService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit

enum LocationManagerError: AppError {
    var errorDescription: String {
        switch self {
        case .badAccuracy:
            return ""
        case .permissionDenied:
            return "Appen skal have tilladelse til at hente din lokation, for at vise dig den her data"
        case .coreLocationError(error: let error):
            return error.localizedDescription
        }
    }
    
    var errorTitle: String {
        switch self {
        case .permissionDenied:
            return "Manglende tilladelse"
        default:
            return ""
        }
    }
    
    case permissionDenied
    case badAccuracy
    case coreLocationError(error: Error)
    
    
}


protocol LocationManagerDelegate: class {
    func locationInaccessible(error: LocationManagerError)
    func userDeniedPermissions()
    func locationRetrieved(location: CLLocation)
}

class LocationManager: NSObject {
    
    private var locationManager: CLLocationManager?
    
    weak var delegate: LocationManagerDelegate? = nil
    private var previousAccuracy: Double = 0.0
    private var latestLocation: CLLocation?
    

    func start() {
        locationManager = CLLocationManager()
        locationManager?.activityType = CLActivityType.other
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.delegate = self
    }

    private func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.locationManager?.stopUpdatingLocation()
            guard let latestLocation = self?.latestLocation else {return}
            self?.delegate?.locationRetrieved(location: latestLocation)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0, location.timestamp.timeIntervalSinceNow < 5 else {return}
        
        latestLocation = location
    
        if location.horizontalAccuracy <= manager.desiredAccuracy {
            latestLocation = nil
            locationManager?.stopUpdatingLocation()
            locationManager = nil
            delegate?.locationRetrieved(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {return}
        debugPrint(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            delegate?.userDeniedPermissions()
        }
    }
}


