//
//  OfflineBackground.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 13/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit
/*
class LocationBackground: UIView {
    
    private lazy var settingsView:  MapViewSettingsView =  {
       let view = MapViewSettingsView(filteringSettings: filteringSettings)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapViewToolBarView: MapViewToolBarView = {
       let view = MapViewToolBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(filteringSettings: filteringSettings)
        view.delegate = self
        return view
    }()
    
    private lazy var mapView: MapView = {
        let mapView = MapView(mapViewConfiguration: MapViewConfiguration(filteringSettings: filteringSettings, mapViewCornerRadius: 0.0, shouldHaveDescriptionView: false))
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        return mapView
    }()
    
    private var filteringSettings = FilteringSettings.init(regionRadius: 1000, age: 1)
    weak var delegate: NavigationDelegate?
    
    
   init() {
    super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mapView.centerOnUserLocation()
        
        addSubview(settingsView)
        settingsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        settingsView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        insertSubview(mapViewToolBarView, belowSubview: settingsView)
        mapViewToolBarView.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor).isActive = true
        mapViewToolBarView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor).isActive = true
        mapViewToolBarView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    deinit {
        mapView.customRelease()
        mapView.delegate = nil
        print("Was Deinited")
    }
    
//    func filterByCategory(category: NearbyVC.Categories) {
//       mapView.filterByCategory(category: category)
//    }
}

extension LocationBackground: MapViewDelegate {
    func userLocationButtonShouldShow(shouldShow: Bool) {
        
    }
    
    func presentVC(_ vc: UIViewController) {
        delegate?.presentVC(vc)
    }
    
    func pushVC(_ vc: UIViewController) {
        delegate?.pushVC(vc)
    }
}

extension LocationBackground: MapViewSettingsViewDelegate {
    func wasCollapsed() {
        mapViewToolBarView.configure(filteringSettings: filteringSettings)
    }
    
    func wasExpanded() {
        mapView.closeCalloutView()
    }
}

extension LocationBackground: MapViewToolBarViewDelegate {
    func handleAnnotationButtonGesture(gesture: UIPanGestureRecognizer) {
        mapView.addLocationPin(gesture: gesture)
    }
}
*/
