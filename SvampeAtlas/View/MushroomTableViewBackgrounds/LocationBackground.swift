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
    
    private lazy var settingsView:  MapViewSettingsView =  {
       let view = MapViewSettingsView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var userLocationButton: UIButton = {
      let button = UIButton()
        button.backgroundColor = UIColor.appSecondaryColour()
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(userLocationButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var mapView: MapView = {
       let mapView = MapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        return mapView
    }()
    
    lazy var listView: ListView = {
       let listView = ListView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.delegate = self
        return listView
    }()
    
    var delegate: MushroomBackgroundDelegate? = nil {
        didSet {
            print("Didset")
        }
    }
    
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
        
        addSubview(settingsView)
        settingsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        settingsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        
        
        
//        self.addSubview(userLocationButton)
//        userLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
//        userLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
//
        mapView.centerOnUserLocation()
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
    
    @objc private func userLocationButtonPressed(_ sender: UIButton) {
        mapView.centerOnUserLocation()
        showsUserLocationButton(false, animated: true)
        
    }
}

extension LocationBackground: MapViewDelegate {
    func userLocationButtonShouldShow(shouldShow: Bool) {
        
    }
    
    func shouldShowObservationDetails(observation: Observation) {
        let vc = ObservationVC(observation: observation)
        vc.view.backgroundColor = UIColor.white
        delegate?.showVC(vc: vc)
    }
    
    
}

extension LocationBackground: MapViewSettingsViewDelegate {
    func newSearch(settings: ObservationSettings) {
        mapView.mapViewConfiguration.changeRegionRadius(intoValue: settings.radius)
        mapView.reset()
    }
}
