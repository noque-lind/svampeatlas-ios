//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import MapKit
import UIKit

class NearbyVC: UIViewController {
    
    private lazy var categoryView: CategoryView<NewMapView.Categories> = {
        let items = NewMapView.Categories.allCases.compactMap({Category<NewMapView.Categories>(type: $0, title: $0.description)})
        let view = CategoryView<NewMapView.Categories>.init(categories: items, firstIndex: 0)
        
        view.categorySelected = { [unowned mapView] category in
            mapView.filterByCategory(category: category)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapView: NewMapView = {
        let view = NewMapView(type: .observations(detailed: true))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.observationPicked = {[weak self] observation in
            self?.navigationController?.pushViewController(DetailsViewController(detailsContent: .observation(observation: observation, showSpeciesView: true), session: self?.session), animated: true)
        }
        
        view.delegate = self
        return view
    }()
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
        
    private lazy var toolBarView: MapViewSettingsView = {
       let view = MapViewSettingsView(mapViewFilteringSettings: self.mapViewFilteringSettings)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.onSearchButtonPressed = { [unowned self] in
            self.mapView.shouldLoad = true
            self.locationManager.start()
        }
        
        view.onAnnotationRelease = { [unowned self] (annotationButton) in
            self.mapView.shouldLoad = true
            let pointAnnotation = self.mapView.addLocationAnnotation(button: annotationButton)
            self.locationManager.state.set(.foundLocation(location: CLLocation.init(latitude: pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)))
        }
        return view
    }()
    
    private lazy var locationManager: LocationManager = {
       let manager = LocationManager()
        manager.state.observe(listener: { [weak self, weak manager] state in
            switch state {
            case .stopped: return
            case .locating: self?.mapView.shouldLoad = true
            case .error(error: let error):
                self?.mapView.showError(error: error, handler: { (recoveryAction) in
                    switch recoveryAction {
                    case .openSettings: UIApplication.openAppSettings()
                    default: manager?.start()
                    }
                })
            case .foundLocation(location: let location):
                guard let mapViewFilteringSettings = self?.mapViewFilteringSettings else {return}
                DataService.instance.getObservationsWithin(geometry: API.Geometry(coordinate: location.coordinate, radius: CLLocationDistance(mapViewFilteringSettings.distance), type: .circle), ageInYear: mapViewFilteringSettings.age) { (result) in
                    self?.mapView.shouldLoad = false
                    switch result {
                    case .failure(let error):
                        self?.mapView.showError(error: error, handler: nil)
                    case .success(let observations):
                        self?.mapView.addObservationAnnotations(observations: observations)
                        guard let mapViewFilteringSettings = self?.mapViewFilteringSettings else {return}
                        self?.mapView.addCirclePolygon(center: location.coordinate, radius: CLLocationDistance(mapViewFilteringSettings.distance))
                    }
                }
            }
        })
        return manager
    }()
    
    private var session: Session?
    private var mapViewFilteringSettings = MapViewFilteringSettings(distance: 1000, age: 1)
    
    init(session: Session?) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
        
        view.addSubview(categoryView)
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        categoryView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    
        view.insertSubview(mapView, belowSubview: categoryView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
        view.addSubview(toolBarView)
        toolBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        toolBarView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toolBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        
        mapView.shouldLoad = true
        setupNavigationController()
        locationManager.start()
    }
    
    private func setupNavigationController() {
        self.title = NSLocalizedString("nearbyVC_title", comment: "")
        
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension NearbyVC: CustomMapViewDelegate {
    func mapViewWillStopRegionChangeAnimated(animated: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.toolBarView.alpha = 1.0
        }
    }
    
    func mapViewWillBeginRegionChangeAnimated(animated: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.toolBarView.alpha = 0.2
        }
        
    }
}
