//
//  MapView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewDelegate: NavigationDelegate {
    func userLocationButtonShouldShow(shouldShow: Bool)
}

class FilteringSettings {
    var regionRadius: CGFloat
   var age: Int
    
    init(regionRadius: CGFloat, age: Int) {
        self.regionRadius = regionRadius
        self.age = age
    }
}

struct MapViewConfiguration {
    public private(set) var filteringSettings: FilteringSettings
    public private(set) var mapViewCornerRadius: CGFloat = 0.0
    public private(set) var shouldHaveDescriptionView: Bool
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
    
//    private lazy var centerOnUserLocationButton: UIButton = {
//       let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        button.backgroundColor = UIColor.appRed()
//        button.addTarget(self, action: #selector(centerOnUserLocationButtonPressed), for: .touchUpInside)
//        return button
//    }()
    
    private var pointAnnotationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if pointAnnotationCoordinate != nil {
                drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius), centerCoordinate: pointAnnotationCoordinate!)
            }
        }
    }
    
    private var userLocationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if let userLocationCoordinate = userLocationCoordinate, let oldValue = oldValue {
                if oldValue.distance(to: userLocationCoordinate) > 20 {
                    drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius), centerCoordinate: userLocationCoordinate)
                } else {
                    setRegion(coordinate: userLocationCoordinate)
                }
            } else if let userLocationCoordinate = userLocationCoordinate {
                if mapViewConfiguration.shouldHaveDescriptionView {
                    let distance = CLLocation(latitude: userLocationCoordinate.latitude, longitude: userLocationCoordinate.longitude).distance(from: CLLocation(latitude: pointAnnotation!.coordinate.latitude, longitude: pointAnnotation!.coordinate.longitude))
                    addContentToDescriptionView(distance: distance)
                    mapView.showAnnotations(mapView.annotations, animated: true)
                } else {
                     drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius), centerCoordinate: userLocationCoordinate)
                }
            }
        }
    }
    
    private var circleOverlay: MKOverlay? {
        didSet {
            downloadDataWithinRect(circleOverlay!.boundingMapRect)
        }
    }
    
    weak var delegate: MapViewDelegate? = nil
    
    private var mapViewConfiguration: MapViewConfiguration
    private var pointAnnotation: MKPointAnnotation?
    private var observations = [Observation]()
    private var locationManager: CLLocationManager!
    private var selectedAnnotationView: MKAnnotationView?
    
    init(mapViewConfiguration: MapViewConfiguration) {
        self.mapViewConfiguration = mapViewConfiguration
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError()
    }
    
    private func setupView() {
        locationManager = CLLocationManager()
        
        addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if mapViewConfiguration.shouldHaveDescriptionView {
            addSubview(descriptionView)
            descriptionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            descriptionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            mapView.topAnchor.constraint(equalTo: descriptionView.centerYAnchor).isActive = true
        } else {
            mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//            addSubview(centerOnUserLocationButton)
//            centerOnUserLocationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
//            centerOnUserLocationButton.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        }
        
        mapView.layer.cornerRadius = mapViewConfiguration.mapViewCornerRadius
        mapView.clipsToBounds = true
    }
    
    private func addContentToDescriptionView(distance: CLLocationDistance) {
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "MapView")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
            return imageView
        }()
        
        let informationStackView = UIStackView()
        informationStackView.axis = .vertical
        informationStackView.distribution = .fillEqually
        informationStackView.translatesAutoresizingMaskIntoConstraints = false

        let upperLabel: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.textAlignment = .center
            let rounded = (Double(distance) / 1000).rounded(toPlaces: 1)
            label.text = "\(rounded) km væk fra dig"
            return label
        }()
        
        informationStackView.addArrangedSubview(upperLabel)

        descriptionView.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16).isActive = true
        imageView.centerYAnchor.constraint(equalTo: descriptionView.centerYAnchor).isActive = true
        
        descriptionView.addSubview(informationStackView)
        informationStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        informationStackView.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 4).isActive = true
        informationStackView.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: -4).isActive = true
        informationStackView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16).isActive = true
    }
    
    func centerOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func showObservationAt(coordinates: [Double]) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.last!, longitude: coordinates.first!)
        pointAnnotation = annotation
        mapView.addAnnotation(annotation)
        centerOnUserLocation()
    }
    
    @objc func addLocationPin(gesture: UIGestureRecognizer) {
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
    
            pointAnnotation?.coordinate = coordinate
    
        switch gesture.state {
        case .began:
            return
        case .ended:
            if pointAnnotation != nil {
                mapView.removeAnnotation(pointAnnotation!)
                pointAnnotation = nil
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            pointAnnotation = annotation
            pointAnnotationCoordinate = coordinate
        default:
            return
        }
    }
    
    @objc private func centerOnUserLocationButtonPressed() {
        centerOnUserLocation()
    }
    
   
    func addObservationAnnotations(observations: [Observation]) {
        let originalElements = self.observations.returnOriginalElements(newElements: observations)
        self.observations.append(contentsOf: originalElements)
        
        var annotations = [ObservationPin]()
        for observation in originalElements {
            let observationPin = ObservationPin(coordinate: CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!), identifier: "observationPin", observation: observation)
            annotations.append(observationPin)
        }
        DispatchQueue.main.async {
             self.mapView.addAnnotations(annotations)
        }
    }
    
    func reset() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        userLocationCoordinate = nil
        centerOnUserLocation()
    }
    
    func closeCalloutView() {
        if let selectedAnnotationView = selectedAnnotationView {
            selectedAnnotationView.setSelected(false, animated: true)
            mapView.delegate?.mapView!(mapView, didDeselect: selectedAnnotationView)
        }
    }
    
    func resetSearchParameter() {
        if let pointAnnotationCoordinate = pointAnnotationCoordinate {
            drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius), centerCoordinate: pointAnnotationCoordinate)
        } else if let userLocationCoordinate = userLocationCoordinate {
            drawCircle(withRadius: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius), centerCoordinate: userLocationCoordinate)
        }
    }
    
    private func drawCircle(withRadius radius: CLLocationDistance, centerCoordinate coordinate: CLLocationCoordinate2D) {
        let circle = MKCircle(center: coordinate, radius: radius)
        circleOverlay = circle
        mapView.addOverlay(circle)
        setRegion(coordinate: coordinate)
    }
    
    private func setRegion(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius * 3), longitudinalMeters: CLLocationDistance.init(mapViewConfiguration.filteringSettings.regionRadius * 3))
        mapView.setRegion(region, animated: true)
    }
    
    private func downloadDataWithinRect(_ rect: MKMapRect) {
        controlActivityIndicator(wantRunning: true)
        
        let coordinate1 = MKMapPoint.init(x: rect.origin.x, y: rect.origin.y).coordinate
        let coordinate2 = MKMapPoint.init(x: rect.origin.x + rect.size.width, y: rect.origin.y).coordinate
        let coordinate3 = MKMapPoint.init(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height).coordinate
        let coordinate4 = MKMapPoint.init(x: rect.origin.x, y: rect.origin.y + rect.size.height).coordinate
        
        let geoJSON = "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[\(coordinate1.longitude),\(coordinate1.latitude)],[\(coordinate2.longitude),\(coordinate2.latitude)],[\(coordinate3.longitude),\(coordinate3.latitude)],[\(coordinate4.longitude),\(coordinate4.latitude)],[\(coordinate1.longitude),\(coordinate1.latitude)]]]}}"
        
        var whereJSON: String?
        
        if let dateString = Date(age: mapViewConfiguration.filteringSettings.age * 12)?.convert(into: "yyyy-MM-dd") {
            whereJSON = "{\"observationDate\":{\"$gte\":\"\(dateString)\"}}"
        }

        DataService.instance.getObservationsWithin(geoJSON: geoJSON, whereQuery: whereJSON) { (appError, mushrooms)  in
            DispatchQueue.main.sync {
            self.controlActivityIndicator(wantRunning: false)
            
            guard appError == nil, let mushrooms = mushrooms else {
                self.delegate?.presentVC(UIAlertController(title: appError!.title, message: appError!.message))
                return
            }
                self.addObservationAnnotations(observations: mushrooms)
            }
        }
    }
    
    func customRelease() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.delegate = nil
        delegate = nil
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
            if observationPin.observation.images?.first != nil {
                var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinViewWithImage") as? ObservationPinView
                observationPinView?.annotation = annotation
                observationPinView?.delegate = self.delegate
                
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinViewWithImage", withImage: true)
                    observationPinView?.delegate = self.delegate
                }
                
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            } else {
                var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinView") as? ObservationPinView
                observationPinView?.annotation = annotation
                
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinView", withImage: false)
                    observationPinView?.delegate = self.delegate
                }
                
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            }
        } else if let clusterPin = annotation as? MKClusterAnnotation {
            var clusterPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterPinView") as? ClusterPinView
            clusterPinView?.annotation = clusterPin
            
            if clusterPinView == nil {
                clusterPinView = ClusterPinView(annotation: clusterPin, reuseIdentifier: "clusterPinView")
                clusterPinView?.delegate = self.delegate
            }
            return clusterPinView
        
        } else if let pointAnnotation = annotation as? MKPointAnnotation {
            var pointAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pointAnnotationView") as? MKPinAnnotationView
            pointAnnotationView?.annotation = pointAnnotation
            
            if pointAnnotationView == nil {
                pointAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pointAnnotationView")
                pointAnnotationView?.animatesDrop = true
                pointAnnotationView?.isDraggable = false
                pointAnnotationView?.canShowCallout = false
                pointAnnotationView?.pinTintColor = UIColor.appPrimaryColour()
            }
            return pointAnnotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotationView = view
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedAnnotationView = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        userLocationCoordinate = coordinate
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
}


