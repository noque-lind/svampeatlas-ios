//
//  MapView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit


fileprivate class CustomMapView: MKMapView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

protocol CustomMapViewDelegate: class {
    func mapViewWillBeginRegionChangeAnimated(animated: Bool)
    func mapViewWillStopRegionChangeAnimated(animated: Bool)
}

class NewMapView: UIView {
    
    enum Categories: String, CaseIterable {
        case regular = "Standard"
        case satelite = "Luftfoto"
        case topography = "Topografisk"
    }
    
    enum MapViewType {
        case observations(detailed: Bool)
        case localities
    }
    
    private lazy var mapView: CustomMapView = {
        let mapView = CustomMapView()
        mapView.delegate = self
        if #available(iOS 13.0, *) {
            mapView.overrideUserInterfaceStyle = .light
        } else {}
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = self.showsUserLocation
        mapView.register(HeatAnnotationView.self, forAnnotationViewWithReuseIdentifier: "heatAnnotationView")
        mapView.register(ClusteredHeatAnnotationView.self, forAnnotationViewWithReuseIdentifier: "clusteredHeatAnnotationView")
        mapView.register(ClusterPinView.self, forAnnotationViewWithReuseIdentifier: "clusterPinView")
        mapView.register(LocalityAnnotationView.self, forAnnotationViewWithReuseIdentifier: "localityAnnotationView")
        mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "locationAnnotationView")
        return mapView
    }()
    
    private lazy var topographicalOverlay: MKTileOverlay = {
       let template = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        overlay.maximumZ = 19
        return overlay
    }()
    
    private var spinner = Spinner()
    private var tempIsUserInteractionEnabled: Bool = true
    private var category = Categories.regular
    private var errorView: ErrorView? {
        willSet {
            if newValue == nil {
                     self.errorView?.removeFromSuperview()
            }
        }
        didSet {
            DispatchQueue.main.async {
                if self.errorView == nil && oldValue != nil {
                    self.isUserInteractionEnabled = self.tempIsUserInteractionEnabled
                } else if !(self.errorView == nil) {
                    self.tempIsUserInteractionEnabled = self.isUserInteractionEnabled
                    self.isUserInteractionEnabled = true
                    self.addSubview(self.errorView!)
                    self.errorView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                    self.errorView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                    self.errorView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                    self.errorView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                }
            }
        }
    }
    
    private let mapViewType: MapViewType
    private var observations: [Observation]?
    private var localities: [Locality]?

    private var locationAnnotation: LocationPIn? {
        didSet {
            if let oldValue = oldValue {
                mapView.removeAnnotation(oldValue)
        }
    }
    }
    
    weak var delegate: CustomMapViewDelegate?
    
    var observationPicked: ((_ observation: Observation) -> ())?
    var localityPicked: ((_ locality: Locality) -> ())?
    var wasTapped: (() -> ())? {
        didSet {
            if wasTapped != nil {
                isUserInteractionEnabled = true
                mapView.isUserInteractionEnabled = false
                let gesture = UITapGestureRecognizer(target: self, action: #selector(gestureWasTapped))
                self.addGestureRecognizer(gesture)
        }
    }
    }
        
        @objc private func gestureWasTapped() {
        wasTapped?()
        }
        
    
    var showsUserLocation: Bool = true {
        didSet {
            mapView.showsUserLocation = self.showsUserLocation
        }
    }
    
    override var layoutMargins: UIEdgeInsets {
        didSet {
            mapView.insetsLayoutMarginsFromSafeArea = false
            mapView.layoutMargins = self.layoutMargins
        }
    }
    
    
    var shouldLoad = false {
        didSet {
            DispatchQueue.main.async {
                switch self.shouldLoad {
                case true:
                    self.spinner.addTo(view: self)
                    self.spinner.start()
                case false:
                    self.spinner.stop()
                    self.spinner.removeFromSuperview()
                }
            }
        }
    }
    
    init(type mapViewType: MapViewType) {
        self.mapViewType = mapViewType
        
        switch mapViewType {
        case .localities:
            self.localities = []
        case .observations:
            self.observations = []
        }
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        DispatchQueue.main.async {
            self.addSubview(self.mapView)
            self.mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            self.mapView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.addSubview(self.spinner)
            self.spinner.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.spinner.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.spinner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            self.spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }
    
    func showError(error: AppError, handler: ((RecoveryAction?) -> ())? = nil) {
        shouldLoad = false
        
        DispatchQueue.main.async {
            let backGroundView: ErrorView = {
                let view = ErrorView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.configure(error: error, handler: handler)
                view.backgroundColor = UIColor.appPrimaryColour()
                return view
            }()
            self.errorView = backGroundView
        }
    }
    
    func setRegion(region: MKCoordinateRegion, selectAnnotationAtCenter: Bool, animated: Bool) {
        mapView.setRegion(region, animated: animated)
        
        
//        guard selectAnnotationAtCenter, let annotation = mapView.annotations.first(where: {$0.coordinate.distance(to: center) == 0}) else {return}
//        mapView.selectAnnotation(annotation, animated: false)
    }
    
    func setRegion(center: CLLocationCoordinate2D, zoomMetres: CLLocationDistance) {
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomMetres, longitudinalMeters: zoomMetres)
        mapView.setRegion(region, animated: false)
    }
    
    func setRegionToShowAnnotations() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func setRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: CLLocationDistance.init(0.0035), longitudeDelta: CLLocationDistance.init(0.0035)), selectAnnotationAtCoordinate: Bool = false, animated: Bool) {
        let region = MKCoordinateRegion.init(center: center, span: span)
        mapView.setRegion(region, animated: animated)
        
        
        guard selectAnnotationAtCoordinate, let annotation = mapView.annotations.first(where: {$0.coordinate.distance(to: center) == 0}) else {return}
        mapView.selectAnnotation(annotation, animated: false)
    }
    
    func selectAnnotationAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let annotation = mapView.annotations.first(where: {$0.coordinate.distance(to: coordinate) == 0}) else {return}
        mapView.selectAnnotation(annotation, animated: false)
    }
    
    func clearAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        localities?.removeAll()
        observations?.removeAll()
    }
    
    
    func addLocalityAnnotations(localities: [Locality]) {
        errorView = nil
        guard let originalElements = self.localities?.returnOriginalElements(newElements: localities), originalElements.count > 0 else {debugPrint("No new items"); return}
        self.localities?.append(contentsOf: originalElements)
            
            var annotations = [LocalityAnnotation]()
            
            for locality in localities {
                let point = LocalityAnnotation(coordinate: CLLocationCoordinate2D(latitude: locality.latitude, longitude: locality.longitude), identifier: "localityAnnotation", locality: locality)
                annotations.append(point)
            
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func addLocationAnnotation(location: CLLocationCoordinate2D) {
        errorView = nil
        let annotation = LocationPIn(coordinate: location)
        mapView.addAnnotation(annotation)
        locationAnnotation = annotation
    }
    
    func addLocationAnnotation(button: UIButton) -> LocationPIn {
        errorView = nil
        let coordinate = mapView.convert(CGPoint(x: button.frame.midX, y: button.frame.maxY), toCoordinateFrom: button.superview)
        let annotation = LocationPIn(coordinate: coordinate)
               mapView.addAnnotation(annotation)
               locationAnnotation = annotation
               return annotation
    }
    
    func addObservationAnnotations(observations: [Observation]) {
        DispatchQueue.main.async {
            switch self.mapViewType {
        case .observations(detailed: let detailed):
            self.errorView = nil
                guard let originalElements = self.observations?.returnOriginalElements(newElements: observations), originalElements.count > 0 else {debugPrint("No new items."); return}
                self.observations?.append(contentsOf: originalElements)
                
                var annotations = [ObservationPin]()
                for observation in originalElements {
                    let observationPin = ObservationPin(coordinate: CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!), identifier: "observationPin", observation: observation, detailed: detailed)
                    annotations.append(observationPin)
                }
                
                
                    self.mapView.addAnnotations(annotations)
              
        case .localities:
            return
        }
            
        }
    }
    
    func addCirclePolygon(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        DispatchQueue.main.async {
            let circle = MKCircle(center: center, radius: radius)
            self.mapView.addOverlay(circle)
            self.setRegion(center: center, zoomMetres: radius * 2.3)
        }
    }
    
    
    func filterByCategory(category: Categories) {
        mapView.removeOverlay(topographicalOverlay)
        
        switch category {
        case .regular:
            mapView.mapType = .mutedStandard
            mapView.showsPointsOfInterest = false
        case .satelite:
            mapView.mapType = .satellite
        case .topography:
            mapView.addOverlay(topographicalOverlay, level: .aboveLabels)
        }
    }
    
}

extension NewMapView: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("Finished loading map")
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        guard let observationPin = memberAnnotations.first as? ObservationPin, observationPin.detailed == false else {return MKClusterAnnotation(memberAnnotations: memberAnnotations)}
        return ClusteredHeatAnnotation(memberAnnotations: memberAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let observationPin = annotation as? ObservationPin {
            return returnAnnotationViewForObservationPin(observationPin)
        } else if let clusteredHeatAnnotation = annotation as? ClusteredHeatAnnotation {
            if let clusteredHeatAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusteredHeatAnnotationView") as? ClusteredHeatAnnotationView {
                clusteredHeatAnnotationView.annotation = clusteredHeatAnnotation
                return clusteredHeatAnnotationView
            }
        } else if let clusterPin = annotation as? MKClusterAnnotation {
            if let clusterPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterPinView") as? ClusterPinView {
                clusterPinView.annotation = clusterPin
                clusterPinView.showObservation = observationPicked
                return clusterPinView
            }
        } else if let localityAnnotation = annotation as? LocalityAnnotation {
            if let localityAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "localityAnnotationView") as? LocalityAnnotationView {
                localityAnnotationView.annotation = localityAnnotation
                return localityAnnotationView
            }
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
        } else if let locationPin = annotation as? LocationPIn {
            var locationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "locationAnnotationView") as? LocationAnnotationView
            locationPinView?.annotation = locationPin
            
            if locationPinView == nil {
                locationPinView = LocationAnnotationView(annotation: locationPin, reuseIdentifier: "locationAnnotationView")
                locationPinView?.canShowCallout = false
                locationPinView?.isDraggable = false
            }
            
            return locationPinView
        } else {
            return nil
        }
        return nil
    }
    
   
    private func returnAnnotationViewForObservationPin(_ observationPin: ObservationPin) -> MKAnnotationView? {
        switch observationPin.detailed {
        case true:
            if observationPin.observation.images?.first != nil {
                var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinViewWithImage") as? ObservationPinView
                observationPinView?.annotation = observationPin
                observationPinView?.wasPressed = observationPicked
                
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinViewWithImage", withImage: true)
                    observationPinView?.wasPressed = observationPicked
                }
                
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            } else {
                var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinView") as? ObservationPinView
                observationPinView?.annotation = observationPin
                observationPinView?.wasPressed = observationPicked
                
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinView", withImage: false)
                     observationPinView?.wasPressed = observationPicked
                }
                
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            }
        case false:
            guard let heatAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "heatAnnotationView") as? HeatAnnotationView else  {fatalError()}
            heatAnnotationView.clusteringIdentifier = "clusteredHeatAnnotation"
            return heatAnnotationView
        }
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.clear
            circle.fillColor = UIColor.appSecondaryColour().withAlphaComponent(0.2)
            circle.lineWidth = 0
            return circle
        } else if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer()
            }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let localityAnnotation = view.annotation as? LocalityAnnotation {
            localityPicked?(localityAnnotation.locality)
            view.isSelected = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        delegate?.mapViewWillBeginRegionChangeAnimated(animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapViewWillStopRegionChangeAnimated(animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.isSelected = false
    }
}

protocol MapViewDelegate: NavigationDelegate {
    func userLocationButtonShouldShow(shouldShow: Bool)
    func localityPicked(locality: Locality)
}

extension MapViewDelegate {
    func localityPicked(locality: Locality) {}
    func userLocationButtonShouldShow(shouldShow: Bool) {}
    func presentVC(_ vc: UIViewController) {}
    func pushVC(_ vc: UIViewController) {}
}

/*
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
    
    private var filteredAnnotations = [MKAnnotation]()
    
//    private lazy var centerOnUserLocationButton: UIButton = {
//       let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        button.backgroundColor = UIColor.appRed()
//        button.addTarget(self, action: #selector(centerOnUserLocationButtonPressed), for: .touchUpInside)
//        return button
//    }()
    
//    func filterByCategory(category: NewMapView.Categories) {
//        switch category {
//        case .withImages:
//            filteredAnnotations = mapView.annotations.filter { (annotation) -> Bool in
//                guard let annotation = annotation as? ObservationPin else {return false}
//                guard let images = annotation.observation.images else {return true}
//                guard images.count > 0 else {return true}
//                return false
//            }
//            mapView.removeAnnotations(filteredAnnotations)
//        case .regular:
//            mapView.addAnnotations(filteredAnnotations)
//            filteredAnnotations.removeAll()
//        }
//    }
    
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
    
    func addLocalityAnnotations(localities: [Locality]) {
        var annotations = [LocalityAnnotation]()
        
        for locality in localities {
            let point = LocalityAnnotation(coordinate: CLLocationCoordinate2D(latitude: locality.latitude, longitude: locality.longitude), identifier: "localityAnnotation", locality: locality)
            annotations.append(point)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
    }
   
    func addObservationAnnotations(observations: [Observation]) {
        let originalElements = self.observations.returnOriginalElements(newElements: observations)
        self.observations.append(contentsOf: originalElements)
        
        var annotations = [ObservationPin]()
        for observation in originalElements {
            let observationPin = ObservationPin(coordinate: CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!), identifier: "observationPin", observation: observation, detailed: true)
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
        
        DataService.instance.getObservationsWithin(geometry: API.Geometry(coordinate: userLocationCoordinate!, radius: API.Radius.hugest.rawValue, type: .circle)) { (result) in
            switch result {
            case .Error(let error):
                self.delegate?.presentVC(UIAlertController(title: error.errorTitle, message: error.errorDescription))
            case .Success(let observations):
                self.addObservationAnnotations(observations: observations)
            }
        }
        
        /*
        Spinner.start(onView: self)
        
        let coordinate1 = MKMapPoint.init(x: rect.origin.x, y: rect.origin.y).coordinate
        let coordinate2 = MKMapPoint.init(x: rect.origin.x + rect.size.width, y: rect.origin.y).coordinate
        let coordinate3 = MKMapPoint.init(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height).coordinate
        let coordinate4 = MKMapPoint.init(x: rect.origin.x, y: rect.origin.y + rect.size.height).coordinate
        
        let geoJSON = "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[\(coordinate1.longitude),\(coordinate1.latitude)],[\(coordinate2.longitude),\(coordinate2.latitude)],[\(coordinate3.longitude),\(coordinate3.latitude)],[\(coordinate4.longitude),\(coordinate4.latitude)],[\(coordinate1.longitude),\(coordinate1.latitude)]]]}}"
        
        var whereJSON: String?
        
        if let dateString = Date(age: mapViewConfiguration.filteringSettings.age * 12)?.convert(into: "yyyy-MM-dd") {
            whereJSON = "{\"observationDate\":{\"$gte\":\"\(dateString)\"}}"
        }

        DataService.instance.getObservationsWithin(geoJSON: geoJSON, whereQuery: whereJSON) { (result) in
            DispatchQueue.main.async {
                Spinner.stop()
                
                switch result {
                case .Error(let error):
                    self.delegate?.presentVC(UIAlertController(title: error.errorTitle, message: error.errorDescription))
                case .Success(let observations):
                    self.addObservationAnnotations(observations: observations)
                }
            }
        }*/
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
        
        } else if let localityAnnotation = annotation as? LocalityAnnotation {
            var localityAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "localityAnnotationView") as? LocalityAnnotationView
            localityAnnotationView?.annotation = localityAnnotation
            
            if localityAnnotationView == nil {
                localityAnnotationView = LocalityAnnotationView(annotation: localityAnnotation, reuseIdentifier: "localityAnnotationView")
            }
            return localityAnnotationView
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
        
        
        if let localityAnnotation = view.annotation as? LocalityAnnotation {
            delegate?.localityPicked(locality: localityAnnotation.locality)
        }
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
    
}/*

 */*/
