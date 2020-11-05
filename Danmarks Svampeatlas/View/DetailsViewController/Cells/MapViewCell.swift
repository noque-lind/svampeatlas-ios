//
//  MapViewCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 02/11/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import Then
import MapKit.MKTypes

class MapViewCell: UITableViewCell {
    private lazy var mapView = NewMapView(type: .observations(detailed: false)).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = CGFloat.cornerRadius()
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
        $0.heightAnchor.constraint(equalToConstant: 300).isActive = true
    })
    
    private lazy var precisionLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.font = UIFont.appPrimary()
    })
    
    private lazy var precisionView = UIView().then({
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.layer.cornerRadius = CGFloat.cornerRadius()
        $0.addSubview(precisionLabel)
        precisionLabel.topAnchor.constraint(equalTo: $0.topAnchor, constant: 2).isActive = true
        precisionLabel.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -2).isActive = true
        precisionLabel.leadingAnchor.constraint(equalTo: $0.leadingAnchor, constant: 4).isActive = true
        precisionLabel.trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: -4).isActive = true
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    deinit {
        print("MapViewCell deinited")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.do({
            $0.addSubview(mapView)
            $0.addSubview(precisionView)
        })

        mapView.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        })
        
        precisionView.do({
            $0.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8).isActive = true
            $0.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -8).isActive = true
        })
    }
    
    func configure(userRegion: MKCoordinateRegion, observations: [Observation]) {
        mapView.setRegion(region: userRegion, selectAnnotationAtCenter: false, animated: true)
        mapView.addObservationAnnotations(observations: observations)
    }
    
    func configure(observation: Observation) {
        guard let latitude = observation.coordinates.last, let longitude = observation.coordinates.first else {return}
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addLocationAnnotation(location: coordinate)
        mapView.setRegion(center: coordinate, zoomMetres: 5000)
        
        guard observation.location != nil else {return}
        precisionView.isHidden = false
        precisionLabel.text = observation.location
//        precisionLabel.text = String.localizedStringWithFormat(NSLocalizedString("Precision %0.2f m.", comment: ""), observation.horizontalAccuracy.rounded(toPlaces: 2))
//        mapView.addCirclePolygon(center: observationLocation.coordinate, radius: observationLocation.horizontalAccuracy, setRegion: false, clearPrevious: true)
//        mapView.setRegion(center: observationLocation.coordinate)
//        mapView.selectAnnotationAtCoordinate(observationLocation.coordinate)
        
    }
}
