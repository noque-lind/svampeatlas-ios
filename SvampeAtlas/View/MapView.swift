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
    
    private lazy var mapView: CustomMapView = {
        let mapView = CustomMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        
        return mapView
    }()
    
    weak var delegate: MapViewDelegate? = nil
    private var locationManager: CLLocationManager!
    private var mapViewRegionDidChangeBecauseOfUserInteration = false
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
            mapViewRegionDidChangeBecauseOfUserInteration = false
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
}

extension MapView: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let observationPin = annotation as? ObservationPin {
            var observationPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "observationPinView")
            
            if observationPinView == nil {
                observationPinView = ObservationPinView(annotation: observationPin, reuseIdentifier: "observationPinView")
            }
            
//            observationPinView?.clusteringIdentifier = "clusterAnnotationView"
            return observationPinView
        } else if let clusterPin = annotation as? MKClusterAnnotation {
            var clusterPinView = mapView.dequeueReusableAnnotationView(withIdentifier: "clusterPinView")
            clusterPinView?.annotation = clusterPin
            
            if clusterPinView == nil {
                clusterPinView = ClusterPinView(annotation: clusterPin, reuseIdentifier: "clusterPinView")
            }
            return clusterPinView
        
        } else {
            return nil
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Was selected")
        self.mapView.selectedAnnotationView = view as! ObservationPinView
        selectedAnnotationView = view as! ObservationPinView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), CLLocationDistance.init(mapViewConfiguration.regionRadius), CLLocationDistance.init(mapViewConfiguration.regionRadius))
        
        let circle = MKCircle(center: location.coordinate, radius: 50000)
        
        mapView.add(circle)
        
        
        //                let coordinate1 = mapView.coordin
        //                let coordinate2 = mapView.convert(CGPoint(x: circle.boundingMapRect.origin.x + circle.boundingMapRect.size.width, y: circle.boundingMapRect.origin.y), toCoordinateFrom: mapView)
        //                let coordinate3 = mapView.convert(CGPoint(x: circle.boundingMapRect.origin.x, y: circle.boundingMapRect.origin.y + circle.boundingMapRect.size.height), toCoordinateFrom: mapView)
        //                let coordinate4 = mapView.convert(CGPoint(x: circle.boundingMapRect.origin.x + circle.boundingMapRect.size.width, y: circle.boundingMapRect.origin.y + circle.boundingMapRect.size.height), toCoordinateFrom: mapView)
        
        
        //        print(coordinate1, coordinate2, coordinate3, coordinate4)
        
        mapViewRegionDidChangeBecauseOfUserInteration = false
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeBecauseOfUserInteration {
            if !hasDownloaded {
            let coordinate1 = mapView.convert(CGPoint(x: mapView.bounds.origin.x, y: mapView.bounds.origin.y), toCoordinateFrom: mapView)
            let coordinate2 = mapView.convert(CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.origin.y), toCoordinateFrom: mapView)
            let coordinate3 = mapView.convert(CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.maxY), toCoordinateFrom: mapView)
            let coordinate4 = mapView.convert(CGPoint(x: mapView.bounds.origin.x, y: mapView.bounds.maxY), toCoordinateFrom: mapView)
            print(coordinate1, coordinate2, coordinate3, coordinate4)
            
            //            let geoJSON =
            //            """
            //            https://svampe.databasen.org/api/observations/specieslist?geometry={"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[\(coordinate1.longitude),\(coordinate1.latitude)],[\(coordinate2.longitude),\(coordinate2.latitude)],[\(coordinate3.longitude),\(coordinate3.latitude)],[\(coordinate4.longitude),\(coordinate4.latitude)],[\(coordinate1.longitude),\(coordinate1.latitude)]]]}}&include=["{\"model\":\"DeterminationView\",\"as\":\"DeterminationView\",\"attributes\":[\"Taxon_id\",\"Recorded_as_id\",\"Taxon_FullName\",\"Taxon_vernacularname_dk\",\"Taxon_RankID\",\"Determination_validation\",\"Taxon_redlist_status\",\"Taxon_path\",\"Recorded_as_FullName\",\"Determination_user_id\",\"Determination_score\",\"Determination_validator_id\"],\"where\":{\"$and\":{\"$or\":{}}}}","{\"model\":\"User\",\"as\":\"PrimaryUser\",\"required\":false,\"where\":{}}","{\"model\":\"Locality\",\"as\":\"Locality\",\"attributes\":[\"_id\",\"name\"],\"where\":{},\"required\":true}"]&where={}
            //            """
            
            let geoJSON = "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[\(coordinate1.longitude),\(coordinate1.latitude)],[\(coordinate2.longitude),\(coordinate2.latitude)],[\(coordinate3.longitude),\(coordinate3.latitude)],[\(coordinate4.longitude),\(coordinate4.latitude)],[\(coordinate1.longitude),\(coordinate1.latitude)]]]}}"
            hasDownloaded = true
            DataService.instance.getObservationsWithin(geoJSON: geoJSON) { (mushroom) in
                DispatchQueue.main.sync {
                    self.addObservationAnnotations(observations: mushroom)
                }
            }
            }
        } else {
            
        mapViewRegionDidChangeBecauseOfUserInteration = true
    
        }
    }
}
