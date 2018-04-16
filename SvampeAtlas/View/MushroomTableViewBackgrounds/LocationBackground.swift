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
    
    lazy var userLocationButton: UIButton = {
      let button = UIButton()
        button.backgroundColor = UIColor.appSecondaryColour()
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(centerOnUserLocation), for: .touchUpInside)
        return button
    }()
    
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
        
        self.addSubview(userLocationButton)
        userLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        userLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        
        locationManager = CLLocationManager()
        
        centerOnUserLocation()
        
        
        // DEV TOOL
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(sender:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
   @objc private func centerOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapViewRegionDidChangeBecauseOfUserInteration = false
        } else {
            userLocationButton.isHidden = true
        }
    }
    
    @objc func addAnnotation(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
        let touchPoint = sender.location(in: self)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
            let mushroomPin = MushroomPin(coordinate: touchCoordinate, identifier: "mushroomPin", mushroom: nil)
        mapView.addAnnotation(mushroomPin)
        } else {
            return
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
    
    
    
    
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        centerOnUserLocation()
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 0
        }
    }
}

extension LocationBackground: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mushroomPin = annotation as? MushroomPin else {return nil}
        var mushroomAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "droppablePinView")
        
        if mushroomAnnotationView == nil {
            mushroomAnnotationView = MushroomAnnotationView(annotation: mushroomPin, reuseIdentifier: "droppablePinView")
        }
        return mushroomAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    
    
    
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
