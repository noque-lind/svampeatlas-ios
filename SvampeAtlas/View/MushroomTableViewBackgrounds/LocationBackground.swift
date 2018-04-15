//
//  OfflineBackground.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 13/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class LocationBackground: UIView {
    
    private var locationManager: CLLocationManager!
    var mapViewRegionDidChangeBecauseOfUserInteration = false

    lazy var mapView: MKMapView = {
      let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        locationManager = CLLocationManager()
        
        centerOnUserLocation()
    }
    
    private func centerOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapViewRegionDidChangeBecauseOfUserInteration = false
        } else {
//            userLocationButton.isHidden = true
        }
    }
    
    private func addAnnotations() {
        
    }
    
    private func showsUserLocationButton(_ shouldShow: Bool, animated: Bool = true) {
        UIView.animate(withDuration: 0.2) {
            if shouldShow {
//                self.userLocationButton.alpha = 1.0
            } else {
//                self.userLocationButton.alpha = 0.0
            }
        }
    }
    
}

extension LocationBackground: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), 500, 500)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        showsUserLocationButton(false)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeBecauseOfUserInteration {
            showsUserLocationButton(true)
        }
        mapViewRegionDidChangeBecauseOfUserInteration = true
    }
}
