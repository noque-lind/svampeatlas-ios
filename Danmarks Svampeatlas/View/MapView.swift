//
//  MapView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import MapKit
import UIKit

extension MKCoordinateRegion {
    func distanceMax() -> CLLocationDistance {
        let furthest = CLLocation(latitude: center.latitude + (span.latitudeDelta/2),
                             longitude: center.longitude + (span.longitudeDelta/2))
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return centerLoc.distance(from: furthest)
    }
}

private class CustomMapView: MKMapView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

protocol CustomMapViewDelegate: AnyObject {
    func mapViewWillBeginRegionChangeAnimated(animated: Bool)
    func mapViewWillStopRegionChangeAnimated(animated: Bool)
}

class NewMapView: UIView {
    
    enum Categories: CaseIterable {
        case regular
        case satelite
        case topography
        
        var description: String {
            switch self {
            case .regular: return NSLocalizedString("mapViewCategories_regular", comment: "")
            case .satelite: return NSLocalizedString("mapViewCategories_satelite", comment: "")
            case .topography: return NSLocalizedString("mapViewCategories_topographical", comment: "")
    }
        }
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
        mapView.insetsLayoutMarginsFromSafeArea = false
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
        overlay.maximumZ = 20
        return overlay
    }()
    
    private var isReady = false
    
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
    private var selectedAnnotation: MKAnnotation?
        
    private var regionToSet: MKCoordinateRegion?
    
    private var locationAnnotation: LocationPIn? {
        didSet {
            if let oldValue = oldValue {
                mapView.removeAnnotation(oldValue)
        }
    }
    }
    
    weak var delegate: CustomMapViewDelegate?
    
    var observationPicked: ((_ observation: Observation) -> Void)?
    var localityPicked: ((_ locality: Locality) -> Void)?
    var wasTapped: (() -> Void)? {
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
    
    var zoom: CLLocationDistance {
        return mapView.region.distanceMax() / 6
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
    
    func showError(error: AppError, handler: ((RecoveryAction?) -> Void)? = nil) {
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
    }
    
    func setRegion(center: CLLocationCoordinate2D, zoomMetres: CLLocationDistance) {
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zoomMetres, longitudinalMeters: zoomMetres)
        mapView.setRegion(region, animated: false)
    }
    
    func setRegionToShowAnnotations() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showSelectedAnnotationAndLocationAnnotation() {
        switch mapViewType {
        case .localities:
            guard let annotation = mapView.selectedAnnotations.first, let second = locationAnnotation else {return}
            mapView.showAnnotations([annotation, second], animated: true)
        default: return
        }
    }

    func setRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: CLLocationDistance.init(0.0035), longitudeDelta: CLLocationDistance.init(0.0035)), selectAnnotationAtCoordinate: Bool = false, animated: Bool) {
        let region = MKCoordinateRegion.init(center: center, span: span)
        mapView.setRegion(region, animated: animated)
        
        guard selectAnnotationAtCoordinate, let annotation = mapView.annotations.first(where: {$0.coordinate.distance(to: center) == 0}) else {return}
        mapView.selectAnnotation(annotation, animated: false)
    }
    
    func setRegion(center: CLLocationCoordinate2D) {
        if mapView.region.span.latitudeDelta < 0.05 {
             mapView.setRegion(MKCoordinateRegion.init(center: center, span: mapView.region.span), animated: true)
        } else {
            mapView.setRegion(MKCoordinateRegion.init(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        }
    }
    
    func selectAnnotationAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let annotation = mapView.annotations.first(where: {$0.coordinate.distance(to: coordinate) == 0}) else {return}
        mapView.selectAnnotation(annotation, animated: true)
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
        let imageView = button.convert(button.imageView?.frame ?? button.frame, to: button.superview)
        let coordinate = mapView.convert(CGPoint(x: button.frame.midX, y: imageView.maxY), toCoordinateFrom: button.superview)
        let annotation = LocationPIn(coordinate: coordinate)
        mapView.addAnnotation(annotation)
        locationAnnotation = annotation
        return annotation
    }
    
    func addObservationAnnotations(observations: [Observation]) {
            switch self.mapViewType {
        case .observations(detailed: let detailed):
            DispatchQueue.main.async {
                self.errorView = nil
            }
            
            DispatchQueue.global(qos: .default).async { [weak self] in
                guard let self = self else {return}
                guard let originalElements = self.observations?.returnOriginalElements(newElements: observations), originalElements.count > 0 else {debugPrint("No new items."); return}
                self.observations?.append(contentsOf: originalElements)

                var annotations = [ObservationPin]()
                for observation in originalElements {
                    let observationPin = ObservationPin(coordinate: CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!), identifier: "observationPin", observation: observation, detailed: detailed)
                    annotations.append(observationPin)
                }

                    self.mapView.addAnnotations(annotations)
            }
        case .localities:
            return
        }
    }
    
    func addCirclePolygon(center: CLLocationCoordinate2D, radius: CLLocationDistance, setRegion: Bool = true, clearPrevious: Bool = false) {
        DispatchQueue.main.async {
            if clearPrevious { self.mapView.overlays.forEach({if $0 is MKCircle { self.mapView.removeOverlay($0) }}) }
            let circle = MKCircle(center: center, radius: radius)
            self.mapView.addOverlay(circle)
            if setRegion { self.setRegion(center: center, zoomMetres: radius * 2.3) }
        }
    }
    
    func filterByCategory(category: Categories) {
        mapView.removeOverlay(topographicalOverlay)
        if #available(iOS 13.0, *) {
            mapView.cameraZoomRange = MKMapView.CameraZoomRange(
                minCenterCoordinateDistance: MKMapCameraZoomDefault,
                maxCenterCoordinateDistance: MKMapCameraZoomDefault)
        }
        
        switch category {
        case .regular:
            mapView.mapType = .mutedStandard
            mapView.showsPointsOfInterest = false
        case .satelite:
            mapView.mapType = .satellite
        case .topography:
            if #available(iOS 13.0, *) {
                mapView.cameraZoomRange = MKMapView.CameraZoomRange(
                    minCenterCoordinateDistance: 300,
                    maxCenterCoordinateDistance: MKMapCameraZoomDefault)
            }
            mapView.addOverlay(topographicalOverlay, level: .aboveLabels)
        }
    }
    
}

extension NewMapView: MKMapViewDelegate {
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
                clusterPinView.showObservation = { [weak self] (observation) in
                    self?.observationPicked?(observation)
                }
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
               
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinViewWithImage", withImage: true)
                }
                observationPinView?.wasPressed = { [weak self] (observation) in
                    self?.observationPicked?(observation)
                }
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            } else {
                var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinView") as? ObservationPinView
                observationPinView?.annotation = observationPin
                
                if observationPinView == nil {
                    observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinView", withImage: false)
                }
                
                observationPinView?.wasPressed = { [weak self] (observation) in
                    self?.observationPicked?(observation)
                }
                
                observationPinView?.clusteringIdentifier = "clusterAnnotationView"
                return observationPinView
            }
        case false:
            guard let heatAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "heatAnnotationView") as? HeatAnnotationView else {fatalError()}
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
        if let selectedAnnotation = selectedAnnotation {
            mapView.view(for: selectedAnnotation)?.isSelected = false
        }
        
        if let localityAnnotation = view.annotation as? LocalityAnnotation {
            localityPicked?(localityAnnotation.locality)
            selectedAnnotation = view.annotation
            view.isSelected = true
            
        } else if let selectedAnnotation = selectedAnnotation, view.annotation is LocationPIn {
            mapView.view(for: selectedAnnotation)?.isSelected = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        delegate?.mapViewWillBeginRegionChangeAnimated(animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapViewWillStopRegionChangeAnimated(animated: animated)
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
