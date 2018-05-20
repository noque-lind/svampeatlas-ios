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
    func shouldShowObservationDetails(observation: Observation)
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
    
    private lazy var mapView: CustomMapView = {
        let mapView = CustomMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        
        return mapView
    }()
    
    weak var delegate: MapViewDelegate? = nil
    private var locationManager: CLLocationManager!
    private var userLocationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if oldValue == nil {
                drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.regionRadius), centerCoordinate: userLocationCoordinate!)
            }
        }
    }
    private var circleOverlay: MKOverlay? {
        didSet {
            downloadDataWithinRect(circleOverlay!.boundingMapRect)
        }
    }
    
    private var mapViewConfiguration: MapViewConfiguration
    private var selectedAnnotationView: ObservationPinView?
    
    var hasDownloaded = false

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
        }
    }
    
   
    func addObservationAnnotations(observations: [Observation]) {
        var annotations = [ObservationPin]()
        for observation in observations {
            guard let geom = observation.geom else {continue}
            let observationPin = ObservationPin(coordinate: CLLocationCoordinate2D.init(latitude: geom.coordinates.last!, longitude: geom.coordinates.first!), identifier: "observationPin", observation: observation)
            annotations.append(observationPin)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func reset() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func drawCircle(withRadius radius: CLLocationDistance, centerCoordinate coordinate: CLLocationCoordinate2D) {
        let circle = MKCircle(center: coordinate, radius: radius)
        circleOverlay = circle
        mapView.add(circle)
    }
    
    private func downloadDataWithinRect(_ rect: MKMapRect) {
        let coordinate1 = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x, rect.origin.y))
        let coordinate2 = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x + rect.size.width, rect.origin.y))
        let coordinate3 = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height))
        let coordinate4 = MKCoordinateForMapPoint(MKMapPointMake(rect.origin.x, rect.origin.y + rect.size.height))
        print(coordinate1, coordinate2, coordinate3, coordinate4)
        
        let geoJSON = "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[\(coordinate1.longitude),\(coordinate1.latitude)],[\(coordinate2.longitude),\(coordinate2.latitude)],[\(coordinate3.longitude),\(coordinate3.latitude)],[\(coordinate4.longitude),\(coordinate4.latitude)],[\(coordinate1.longitude),\(coordinate1.latitude)]]]}}"
        hasDownloaded = true
        DataService.instance.getObservationsWithin(geoJSON: geoJSON) { (mushroom) in
            DispatchQueue.main.sync {
                self.addObservationAnnotations(observations: mushroom)
            }
        }
    }
    
}

extension MapView: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.clear
            circle.fillColor = UIColor.appSecondaryColour().withAlphaComponent(0.1)
            circle.lineWidth = 0
            return circle
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let observationPin = annotation as? ObservationPin {
            var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinView") as? ObservationPinView
            
            if observationPinView == nil {
                observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinView")
                observationPinView?.delegate = self.delegate
            }
            
            observationPinView?.clusteringIdentifier = "clusterAnnotationView"
            return observationPinView
        } else if let clusterPin = annotation as? MKClusterAnnotation {
            var clusterPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterPinView") as? ClusterPinView
            clusterPinView?.annotation = clusterPin
            
            if clusterPinView == nil {
                clusterPinView = ClusterPinView(annotation: clusterPin, reuseIdentifier: "clusterPinView")
                clusterPinView?.delegate = self.delegate
            }
            return clusterPinView
        
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        userLocationCoordinate = coordinate
        let region = MKCoordinateRegionMakeWithDistance(coordinate, CLLocationDistance.init(mapViewConfiguration.regionRadius), CLLocationDistance.init(mapViewConfiguration.regionRadius))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
}
