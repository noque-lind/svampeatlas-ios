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
    
    private lazy var retryButton = UIButton().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.addTarget(self, action: #selector(getNearbyLocalities), for: UIControl.Event.touchUpInside)
        let size: CGFloat = 40
        $0.widthAnchor.constraint(equalToConstant: size).isActive = true
        $0.heightAnchor.constraint(equalToConstant: size).isActive = true
        let inset = (size / 2) - 14
        $0.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        $0.setImage(#imageLiteral(resourceName: "Glyphs_Reload"), for: [])
        $0.layer.cornerRadius = CGFloat.cornerRadius()
    })
    
    private lazy var precisionLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.font = UIFont.appPrimary()
    })
    
    private lazy var annotationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appGreen().withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(annotationButtonPressed), for: .touchUpInside)
        let size: CGFloat = 40
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        let inset = (size / 2) - 14
        button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_Location_Alternative"), for: [])
        button.layer.shadowOffset = CGSize.shadowOffset()
        button.layer.shadowOpacity = Float.shadowOpacity()
        button.layer.cornerRadius = CGFloat.cornerRadius()
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
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout().then({$0.scrollDirection = .horizontal}))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0.0, left: 32, bottom: 0.0, right: 32)
        view.clipsToBounds = false
        view.register(LocalityCell.self, forCellWithReuseIdentifier: "localityCell")
        return view
    }()
    
    private var localities = [Locality]()
    private weak var newObservation: NewObservation?
    private weak var locationManager: LocationManager?
    weak var delegate: NavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (frame.height - collectionView.frame.minY) + 8, right: 0.0)
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
        contentView.addSubview(collectionView)
        collectionView.do({
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        })
        
        contentView.addSubview(retryButton)
        retryButton.do({
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        })
        
        contentView.addSubview(annotationButton)
        annotationButton.do({
            $0.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 8).isActive = true
            $0.centerXAnchor.constraint(equalTo: retryButton.centerXAnchor).isActive = true
        })
        
        let precisionView = UIView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            $0.layer.cornerRadius = CGFloat.cornerRadius()
            $0.addSubview(precisionLabel)
            precisionLabel.topAnchor.constraint(equalTo: $0.topAnchor, constant: 2).isActive = true
            precisionLabel.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -2).isActive = true
            precisionLabel.leadingAnchor.constraint(equalTo: $0.leadingAnchor, constant: 4).isActive = true
            precisionLabel.trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: -4).isActive = true
        })
        
        contentView.addSubview(precisionView)
        precisionView.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        })
    }
    
    @objc private func getNearbyLocalities() {
        locationManager?.start()
    }
    
    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.15) {
                self.annotationButton.backgroundColor = UIColor.clear
            }
            let location = gesture.location(in: self)
            annotationButton.transform = annotationButton.transform.translatedBy(x: location.x - annotationButton.center.x, y: location.y - annotationButton.center.y)
            gesture.setTranslation(CGPoint(x: 0, y: -24), in: superview)
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
        case .changed:
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint.zero, in: superview)
        case .ended:
            annotationButton.backgroundColor = UIColor.appGreen().withAlphaComponent(0.5)
            let annotation = mapView.addLocationAnnotation(button: annotationButton)
            locationManager?.state.set(.foundLocation(location: CLLocation(coordinate: annotation.coordinate, altitude: -1, horizontalAccuracy: CLLocationAccuracy(mapView.zoom), verticalAccuracy: -1, timestamp: Date())))
            annotationButton.transform = CGAffineTransform.identity
        default:
            return
        }
    }
    
    @objc private func annotationButtonPressed() {
        delegate?.presentVC(TermsVC(terms: .localityHelper))
    }
    
    private func didSelectLocality(locality: Locality) {
        self.newObservation?.locality = locality
        guard let row = self.localities.firstIndex(of: locality) else {return}
        self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        self.mapView.selectAnnotationAtCoordinate(locality.location.coordinate)
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
        
        if let locality = newObservation.locality {
            didSelectLocality(locality: locality)
        }
        
        if let observationLocation = newObservation.observationCoordinate {
            mapView.addLocationAnnotation(location: observationLocation.coordinate)
            precisionLabel.text = String.localizedStringWithFormat(NSLocalizedString("Precision %0.2f m.", comment: ""), observationLocation.horizontalAccuracy.rounded(toPlaces: 2))
            mapView.addCirclePolygon(center: observationLocation.coordinate, radius: observationLocation.horizontalAccuracy, setRegion: false, clearPrevious: true)
            mapView.setRegion(center: observationLocation.coordinate)
            mapView.selectAnnotationAtCoordinate(observationLocation.coordinate)
        }
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
        if localities.count >= 3 {
            return CGSize(width: 200, height: collectionView.frame.height)
        } else if localities.count == 2 {
            return CGSize(width: (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right) / 2, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectLocality(locality: localities[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LocalityCell)?.isSelected = localities[indexPath.row] == newObservation?.locality
    }
}
