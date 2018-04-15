//
//  MapVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userLocationButton: UIButton!
    
    private var locationManager: CLLocationManager!
    var mapViewRegionDidChangeBecauseOfUserInteration = false
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        centerOnUserLocation()
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 0
        }
    }
    
    

    override func viewDidLoad() {
        mapView.delegate = self
    
        super.viewDidLoad()
setupView()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        userLocationButton.layer.cornerRadius = userLocationButton.frame.height / 2
        super.viewDidLayoutSubviews()
    }
    
    private func setupView() {
        userLocationButton.backgroundColor = UIColor.appSecondaryColour()
        userLocationButton.layer.shadowOpacity = 0.4

        locationManager = CLLocationManager()
        mapView.showsUserLocation = true
        centerOnUserLocation()
       
    }
    
    
    private func centerOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapViewRegionDidChangeBecauseOfUserInteration = false
        } else {
            userLocationButton.isHidden = true
        }
    }
    
    private func addAnnotations() {
        
    }
    
    
    private func showsUserLocationButton(_ shouldShow: Bool, animated: Bool = true) {
        UIView.animate(withDuration: 0.2) {
            if shouldShow {
                self.userLocationButton.alpha = 1.0
            } else {
                self.userLocationButton.alpha = 0.0
            }
        }
    }
}


extension MapVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
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
