//
//  ObservationLocationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit
import UIKit

class ObservationLocationCell: UICollectionViewCell {

    private lazy var settingsButton = IconButton().then({
        $0.addTarget(self, action: #selector(openSettingsModal), for: UIControl.Event.touchUpInside)
        $0.setImage(#imageLiteral(resourceName: "Glyphs_Settings"), for: [])
    })

    private lazy var retryButton = IconButton().then({
        $0.addTarget(self, action: #selector(getNearbyLocalities), for: UIControl.Event.touchUpInside)
        $0.setImage(#imageLiteral(resourceName: "Glyphs_Reload"), for: [])
    })
    
    private lazy var precisionLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.font = UIFont.appPrimary()
    })
    
    private lazy var annotationButton = IconButton().then({
        $0.backgroundColor = UIColor.appGreen().withAlphaComponent(0.5)
        $0.addTarget(self, action: #selector(annotationButtonPressed), for: .touchUpInside)
        $0.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_Location_Alternative"), for: [])
        $0.layer.shadowOffset = CGSize.shadowOffset()
        $0.layer.shadowOpacity = Float.shadowOpacity()
        $0.layer.cornerRadius = CGFloat.cornerRadius()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        $0.addGestureRecognizer(panGestureRecognizer)
    })
    
    private lazy var mapView: NewMapView = {
        let view = NewMapView(type: .localities)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsUserLocation = false
        view.filterByCategory(category: .regular)
        view.localityPicked = { [unowned self] locality in
            if locality != self.viewModel?.locality.value?.locality {
                self.viewModel?.setLocality(locality: locality)
            }
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
    weak var viewModel: AddObservationViewModel? {
        didSet {
            viewModel?.observationLocation.observe(listener: { [weak self] state in
                switch state {
                case .error(error: let error, handler: let handler):
                    self?.mapView.showError(error: error as! AppError, handler: handler)
                case .items(item: let item):
                    self?.configureLocation(location: item.item, locked: item.locked)
                default: return
                }
            })
            
            viewModel?.localities.observe(listener: { [weak self] state in
                switch state {
                case .items(item: let items): self?.configureLocalities(localities: items)
                default: return
                }
            })
            
            
            viewModel?.locality.observe(listener: { [weak self] locality in
                if let locality = locality {
                    self?.configureLocality(locality: locality.locality, locked: locality.locked)
                }
            })
        }
    }
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
//        mapView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (frame.height - collectionView.frame.minY) + 8, right: 0.0)
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor.clear
        
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
        
        contentView.do({
            $0.addSubview(mapView)
            $0.addSubview(collectionView)
            $0.addSubview(settingsButton)
            $0.addSubview(retryButton)
            $0.addSubview(annotationButton)
            $0.addSubview(precisionView)
        })
        
        mapView.do({
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        })

        collectionView.do({
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        })
        
            settingsButton.do({
                $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
                $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            })
            
        retryButton.do({
            $0.leadingAnchor.constraint(equalTo: settingsButton.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 8).isActive = true
        })
        
        annotationButton.do({
            $0.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 8).isActive = true
            $0.centerXAnchor.constraint(equalTo: retryButton.centerXAnchor).isActive = true
        })
            
        
        precisionView.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        })
    }
    
    @objc private func getNearbyLocalities() {
        viewModel?.refindLocation()
    }

    @objc private func openSettingsModal() {
        let localityLockPossible: Bool
        switch viewModel?.context {
        case .newNote, .editNote, .edit:
            localityLockPossible = false
        default: localityLockPossible = true
        }
        
        let vc = LocalitySettingsModal(locationLocked: viewModel?.observationLocation.value?.item?.locked ?? false, localityLocked: viewModel?.locality.value?.locked ?? false, localityLockPossible: localityLockPossible)
        
        vc.localityLockedSet = { [weak self] value in
            self?.viewModel?.setLocalityLockedState(locked: value)
        }
        vc.locationLockedSet = { [weak self] value in
            self?.viewModel?.setLocationLockedState(locked: value)
        }
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.permittedArrowDirections = [.up, .left]
        vc.popoverPresentationController?.sourceView = settingsButton
        delegate?.presentVC(vc)
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
            viewModel?.setCustomLocation(location: .init(coordinate: annotation.coordinate, altitude: -1, horizontalAccuracy: CLLocationAccuracy(mapView.zoom), verticalAccuracy: -1, timestamp: Date()))
            annotationButton.transform = CGAffineTransform.identity
        default:
            return
        }
    }
    
    @objc private func annotationButtonPressed() {
        delegate?.presentVC(ModalVC(terms: .localityHelper))
    }
            
    private func configureLocalities(localities: [Locality]) {
        self.localities = localities
        collectionView.reloadData()
        mapView.addLocalityAnnotations(localities: localities)
    }
    
    private func configureLocation(location: CLLocation, locked: Bool) {
        mapView.clearAnnotations()
        mapView.addLocationAnnotation(location: location.coordinate)
        precisionLabel.text = (locked ? "🔒 ": "") + String.localizedStringWithFormat(NSLocalizedString("precision", comment: ""), location.horizontalAccuracy.rounded(toPlaces: 2))
        mapView.addCirclePolygon(center: location.coordinate, radius: location.horizontalAccuracy, setRegion: false, clearPrevious: true)
        mapView.setRegion(center: location.coordinate)
    }
    
    private func configureLocality(locality: Locality, locked: Bool) {
        self.collectionView.reloadData()
        self.mapView.selectAnnotationAtCoordinate(locality.location.coordinate)
        if let selected = collectionView.indexPathsForSelectedItems {
            collectionView.reloadItems(at: selected)
        }
    
        guard let row = self.localities.firstIndex(of: locality) else {return}
        self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
}

///CollectionView Extension
extension ObservationLocationCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "localityCell", for: indexPath) as! LocalityCell
        let locality = localities[indexPath.row]
        cell.configureCell(locality: localities[indexPath.row], locked: (viewModel?.locality.value?.locked ?? false) ? locality.id == viewModel?.locality.value?.locality.id: false)
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
        viewModel?.setLocality(locality: localities[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LocalityCell)?.isSelected = localities[indexPath.row] == viewModel?.locality.value?.locality
    }
}
