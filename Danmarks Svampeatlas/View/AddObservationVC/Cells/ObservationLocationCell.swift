//
//  ObservationLocationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class ObservationLocationCell: UICollectionViewCell {
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(getNearbyLocalities), for: UIControl.Event.touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.setImage(#imageLiteral(resourceName: "Reload"), for: [])
        button.layer.cornerRadius = 12.5
        return button
    }()
    
    private lazy var annotationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "MKAnnotationPinSolid"), for: UIControl.State.normal)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        button.addGestureRecognizer(panGestureRecognizer)
        return button
    }()
    
    private lazy var mapView: NewMapView = {
        let view = NewMapView(type: .localities)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsUserLocation = false
        view.filterByCategory(category: .topography)
        view.localityPicked = { [unowned self] locality in
            self.didSelectLocality(locality: locality)
        }
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0.0, left: 16, bottom: 0.0, right: 16)
        view.clipsToBounds = false
        view.register(LocalityCell.self, forCellWithReuseIdentifier: "localityCell")
        return view
    }()
    
    private var localities = [Locality]()
    private weak var newObservation: NewObservation?
    private weak var locationManager: LocationManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        mapView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (frame.height - collectionView.frame.minY) + 8, right: 0.0)
        super.layoutSubviews()
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        contentView.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        contentView.addSubview(retryButton)
        retryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        retryButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        contentView.addSubview(annotationButton)
        annotationButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 8).isActive = true
        annotationButton.centerXAnchor.constraint(equalTo: retryButton.centerXAnchor).isActive = true
    }
    
    @objc private func getNearbyLocalities() {
        locationManager?.start()
    }
    
    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self)
            annotationButton.transform = annotationButton.transform.translatedBy(x: location.x - annotationButton.center.x, y: location.y - annotationButton.center.y)
            gesture.setTranslation(CGPoint(x: 0, y: -17), in: superview)
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
        case .changed:
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint.zero, in: superview)
        case .ended:
            let annotation = mapView.addPointAnnotation(gesture: gesture)
            locationManager?.delegate?.locationRetrieved(location: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            annotationButton.transform = CGAffineTransform.identity
        default:
            return
        }
    }
    
    private func didSelectLocality(locality: Locality) {
        self.newObservation?.locality = locality
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let row = self.localities.firstIndex(of: locality) else {return}
            self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            self.mapView.selectAnnotationAtCoordinate(locality.location.coordinate)
        }
    }
    
    
    func configureCell(locationManager: LocationManager, newObservation: NewObservation, localities: [Locality]) {
        if mapView.superview == nil {
            mapView.alpha = 0
            collectionView.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.contentView.insertSubview(self.mapView, at: 0)
                self.mapView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                self.mapView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                self.mapView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                self.mapView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.mapView.alpha = 1
                    self.collectionView.alpha = 1
                })
            }
        }
        
        self.locationManager = locationManager
        self.newObservation = newObservation
        self.localities = localities
       
        collectionView.reloadData()
        mapView.clearAnnotations()
        mapView.addLocalityAnnotations(localities: localities)
        if let observationLocation = newObservation.observationCoordinate {
            mapView.addPointAnnotation(coordinate: observationLocation.coordinate)
        }

        mapView.setRegionToShowAnnotations()
            guard let locality = newObservation.locality else {return}
            self.didSelectLocality(locality: locality)
        }
}


///CollectionView Extension
extension ObservationLocationCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "localityCell", for: indexPath) as! LocalityCell
        cell.configureCell(locality: localities[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectLocality(locality: localities[indexPath.row])
    }
}
