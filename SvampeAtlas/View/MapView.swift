//
//  MapView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewDelegate: class {
    func userLocationButtonShouldShow(shouldShow: Bool)
}

struct MapViewConfiguration {
    struct DescriptionViewContent {
        public private(set) var numberOfAnnotations: Int
        public private(set) var withinRangeOf: String
    }
    
    public private(set) var regionRadius: CGFloat = 500
    public private(set) var mapViewCornerRadius: CGFloat = 0.0
    public private(set) var descriptionViewContent: DescriptionViewContent?
}

class MapView: UIView {
    
    private lazy var descriptionView: UIView = {
       let descriptionView = UIView()
        descriptionView.backgroundColor = UIColor.appPrimaryColour()
        descriptionView.layer.cornerRadius = 10
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        descriptionView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        descriptionView.layer.shadowOpacity = 0.4
        descriptionView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        return descriptionView
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        return mapView
    }()
    
    weak var delegate: MapViewDelegate? = nil
    private var locationManager: CLLocationManager!
    private var mapViewRegionDidChangeBecauseOfUserInteration = false
    private var mapViewConfiguration: MapViewConfiguration

    init(mapViewConfiguration: MapViewConfiguration = MapViewConfiguration()) {
        self.mapViewConfiguration = mapViewConfiguration
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.mapViewConfiguration = MapViewConfiguration()
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        locationManager = CLLocationManager()
        
        addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        if let descriptionViewContent = mapViewConfiguration.descriptionViewContent {
            addSubview(descriptionView)
            descriptionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            descriptionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            mapView.topAnchor.constraint(equalTo: descriptionView.centerYAnchor).isActive = true
            addContentToDescriptionView(descriptionViewContent: descriptionViewContent)
        } else {
            mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        
        mapView.layer.cornerRadius = mapViewConfiguration.mapViewCornerRadius
        mapView.clipsToBounds = true
    }
    
    private func addContentToDescriptionView(descriptionViewContent content: MapViewConfiguration.DescriptionViewContent) {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 5
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "IMG_15270"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        contentStackView.addArrangedSubview(iconImageView)
        
        let informationStackView = UIStackView()
        informationStackView.axis = .vertical
        informationStackView.distribution = .fillEqually
        
        let numberOfAnnotationsLabel = UILabel()
        numberOfAnnotationsLabel.font = UIFont.appPrimaryHightlighed()
        numberOfAnnotationsLabel.textColor = UIColor.appWhite()
        numberOfAnnotationsLabel.textAlignment = .center
        numberOfAnnotationsLabel.text = "\(content.numberOfAnnotations) fund nær dig"
    
        let radiusLabel = UILabel()
        radiusLabel.font = UIFont.appPrimary()
        radiusLabel.textAlignment = .center
        radiusLabel.textColor = UIColor.appWhite()
        radiusLabel.text = "Indenfor \(content.withinRangeOf)"
        
        informationStackView.addArrangedSubview(numberOfAnnotationsLabel)
        informationStackView.addArrangedSubview(radiusLabel)
        contentStackView.addArrangedSubview(informationStackView)
        
        descriptionView.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16).isActive = true
        contentStackView.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 4).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -4).isActive = true
    }
    
    func centerOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapViewRegionDidChangeBecauseOfUserInteration = false
        }
    }
    
    // TODO: REMOVE
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
}

extension MapView: MKMapViewDelegate, CLLocationManagerDelegate {
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
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), CLLocationDistance.init(mapViewConfiguration.regionRadius), CLLocationDistance.init(mapViewConfiguration.regionRadius))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeBecauseOfUserInteration {

        }
        mapViewRegionDidChangeBecauseOfUserInteration = true
    }
}
