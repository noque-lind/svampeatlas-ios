//
//  NewObservationVC2.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import CoreLocation
import ELKit

class AddObservationVC: UIViewController {
    
    private enum ObservationCategories: CaseIterable {
        case Species
        case Details
        case Location
        
        var description: String {
            switch self {
            case .Species: return NSLocalizedString("addObservationVC_observationCategories_species", comment: "")
            case .Details: return NSLocalizedString("addObservationVC_observationCategories_details", comment: "")
            case .Location: return NSLocalizedString("addObservationVC_observationCategories_location", comment: "")
            }
        }
    }
    
    private lazy var observationImagesView: ObservationImagesView = {
        let view = ObservationImagesView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isExpanded = !(newObservation.images.count == 0)
        let heightAnchor = view.heightAnchor.constraint(equalToConstant: view.isExpanded ? ObservationImagesView.expandedHeight: ObservationImagesView.collapsedHeight)
        heightAnchor.isActive = true
        
        view.shouldAnimateHeight = { [weak self] constant in
            heightAnchor.constant = constant
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self?.view.layoutIfNeeded()
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }) { (_) in
            }
        }
        
        view.imageDeleted = { [weak newObservation] imageURL in
            newObservation?.removeImage(imageURL: imageURL)
        }
        
        view.onAddImageButtonPressed = { [weak self, weak view, weak newObservation] in
            let vc = CameraVC(cameraVCUsage: .imageCapture)
            vc.onImageCaptured = { imageURL in
                newObservation?.appendImage(imageURL: imageURL)
                view?.addImage(imageURL: imageURL)
                if let imageLocation = newObservation?.returnImageLocationIfNecessary(imageURL: imageURL) {
                    self?.handleImageLocation(imageLocation: imageLocation, alternativeLocation: nil)
                }
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.presentVC(nav)
        }
        
        return view
    }()
    
    private lazy var categoryView: CategoryView<ObservationCategories> = {
        let items = ObservationCategories.allCases.compactMap({Category<ObservationCategories>(type: $0, title: $0.description)})
        let view = CategoryView<ObservationCategories>.init(categories: items, firstIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.categorySelected = { [unowned collectionView, unowned self] category in
            guard let index = ObservationCategories.allCases.firstIndex(of: category) else {return}
            collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            self.view.endEditing(true)
        }
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset = UIEdgeInsets.zero
        view.dataSource = self
        view.register(ObservationDetailsCell.self, forCellWithReuseIdentifier: "observationDetailsCell")
        view.register(ObservationLocationCell.self, forCellWithReuseIdentifier: "observationLocationCell")
        view.register(ObservationSpecieCell.self, forCellWithReuseIdentifier: "observationSpecieCell")
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private lazy var locationManager: LocationManager = {
        let manager = LocationManager()
        manager.state.observe(listener: { [weak manager, weak categoryView, weak self] state in
            categoryView?.setCategoryLoadingState(category: Category(type: ObservationCategories.Location, title: ObservationCategories.Location.description), loading: false)
            switch state {
            case .stopped: return
            case .error(error: let error):
                let notif: ELNotificationView
                switch error.recoveryAction {
                case .openSettings:
                notif = ELNotificationView.appNotification(style: .error(actions: [
                                           .neutral(error.recoveryAction?.localizableText, {
                                               UIApplication.openSettings()
                                           })
                                       ]),location: .bottom)
                default:
                    notif = ELNotificationView.appNotification(style: .error(actions: [
                                               .neutral(error.recoveryAction?.localizableText, { [weak manager] in
                                                   manager?.start()
                                               })
                                           ]), location: .bottom)
                   
                }
                notif.configure(primaryText: error.title, secondaryText: error.message)
                notif.show(animationType: .fromBottom)
            case .locating: categoryView?.setCategoryLoadingState(category: Category(type: ObservationCategories.Location, title: ObservationCategories.Location.description), loading: true)
            case .foundLocation(location: let location):
                // If horizontalAccuracy is 0, it means that it is a Location object created manually on the locality page, thus it should not ask the user wether the image metadata should be used.
                
                guard location.horizontalAccuracy > 0 else {
                    self?.newObservation.observationCoordinate = location
                    self?.findLocality(location: location)
                    return
                }
                
                if let imageLocation = self?.newObservation.returnImageLocationIfNecessary(location: location) {
                    self?.handleImageLocation(imageLocation: imageLocation, alternativeLocation: location)
                } else {
                    self?.newObservation.observationCoordinate = location
                    self?.findLocality(location: location)
                }
            }
        })
        return manager
    }()
    
    private var session: Session
    private var newObservation: NewObservation
    private var localities = [Locality]()
    
    init(newObservation: NewObservation? = nil, session: Session) {
        self.session = session
        if let newObservation = newObservation {
            self.newObservation = newObservation
        } else {
            self.newObservation = NewObservation()
        }
        
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
        }
        
    private func setupView() {
        title = NSLocalizedString("addObservationVC_title", comment: "")
    
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_Upload"), style: .plain, target: self, action: #selector(beginObservationUpload)), animated: false)
        
        view.backgroundColor = UIColor.appPrimaryColour()
        
        let gradientView: GradientView = {
            let view = GradientView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        view.addSubview(gradientView)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(observationImagesView)
        observationImagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        observationImagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        observationImagesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view.addSubview(categoryView)
        categoryView.topAnchor.constraint(equalTo: observationImagesView.bottomAnchor).isActive = true
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func configure() {
        observationImagesView.configure(imageURLS: newObservation.images)
        collectionView.reloadData()
        categoryView.moveSelector(toCellAtIndexPath: IndexPath.init(row: 0, section: 0))
        locationManager.start()
    }
        
    private func reset() {
        newObservation = NewObservation()
        configure()
        collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
    
    @objc private func beginObservationUpload(overrideLowAccuracy: Bool = false) {
        switch newObservation.returnAsDictionary(user: session.user, overrideLowAccuracy: overrideLowAccuracy) {
        case .success(let dict):
            Spinner.start(onView: self.navigationController?.view)
        
            session.uploadObservation(dict: dict, imageURLs: newObservation.images) { [weak self] (result) in
                Spinner.stop()
                DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if data.uploadedImagesCount == self?.newObservation.images.count {
                        ELNotificationView.appNotification(style: .success, primaryText: NSLocalizedString("addObservationVC_successfullUpload_title", comment: ""), secondaryText: "ID: \(data.observationID)", location: .bottom)
                            .show(animationType: .fromBottom, onViewController: self)
                    } else {
                        ELNotificationView.appNotification(style: .warning(actions: nil), primaryText: NSLocalizedString("addObservationVC_successfullUpload_title", comment: ""), secondaryText: String(format: NSLocalizedString("Although an error occured uploading the image/s. %d out of %d images has been successfully uploaded", comment: ""), data.uploadedImagesCount, self?.newObservation.images.count ?? 0), location: .bottom)
                            .show(animationType: .fromBottom, onViewController: self)
                    }
                    
                    self?.newObservation.images.forEach({ELFileManager.deleteImage(imageURL: $0)})
                    self?.reset()
                    
                    
                case .failure(let error):
                    ELNotificationView.appNotification(style: .error(actions: nil), primaryText: error.title, secondaryText: error.message, location: .bottom)
                        .show(animationType: .fromBottom, onViewController: self)
                }
                }
            }
        case .failure(let error):
            self.handleUncompleteObservation(newObservationError: error)
        }
    }
    
    private func handleUncompleteObservation(newObservationError error: NewObservation.Error) {
        var indexPath: IndexPath

        var notificationView = ELNotificationView(style: .error(actions: nil), attributes: ELNotificationView.Attributes.appAttributes())
        switch error {
        case .noMushroom:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Species)! , section: 0)
        case .noSubstrateGroup, .noVegetationType:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Details)! , section: 0)
        case .noLocality, .noCoordinates:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Location)! , section: 0)
        case .lowAccuracy:
            notificationView = ELNotificationView(style: .action(backgroundColor: UIColor.appYellow(), actions: [
            .positive(NSLocalizedString("Yes, find my current location", comment: ""), { [weak locationManager] in
                locationManager?.start()
            }),
            .neutral(NSLocalizedString("No, continue with the upload", comment: ""), { [weak self] in
                self?.beginObservationUpload(overrideLowAccuracy: true)
            }),
                .negative(NSLocalizedString("Cancel upload", comment: ""), {})
            ]), attributes: ELNotificationView.Attributes.appAttributes())
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Location)!, section: 0)
        }
        notificationView.configure(primaryText: error.title, secondaryText: error.message)
        notificationView.show(animationType: .fromBottom ,queuePosition: .front, onViewController: self)
        categoryView.moveSelector(toCellAtIndexPath: indexPath)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
    
    private func handleImageLocation(imageLocation: CLLocation, alternativeLocation: CLLocation?) {
        ELNotificationView.appNotification(style: .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
        .positive(NSLocalizedString("addObservationVC_useImageMetadata_positive", comment: ""), { [unowned newObservation, unowned self] in
            newObservation.observationCoordinate = imageLocation
            newObservation.observationDate = imageLocation.timestamp
            self.collectionView.reloadItems(at: [IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Details)!, section: 0)])
            self.findLocality(location: imageLocation)
        }),
        .negative(NSLocalizedString("addObservationVC_useImageMetadata_negative", comment: ""), { [unowned newObservation, unowned self] in
            if let alternativeLocation = alternativeLocation {
                newObservation.observationCoordinate = alternativeLocation
                           self.findLocality(location: alternativeLocation)
            }
        })]), primaryText: NSLocalizedString("addObservationVC_useImageMetadata_title", comment: ""), secondaryText: String(format: NSLocalizedString("addObservationVC_useImageMetadata_message", comment:""), "\(imageLocation.horizontalAccuracy.rounded(toPlaces: 2))"), location: .bottom)
        .show(animationType: .fromBottom, onViewController: self)
    }
}

extension AddObservationVC {
    private func findLocality(location: CLLocation) {
        categoryView.setCategoryLoadingState(category: Category(type: ObservationCategories.Location, title: ObservationCategories.Location.description), loading: true)
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { [weak self, weak locationManager, weak newObservation, weak collectionView, weak categoryView] result in
            DispatchQueue.main.async {
                categoryView?.setCategoryLoadingState(category: Category(type: ObservationCategories.Location, title: ObservationCategories.Location.description), loading: false)
            }
            switch result {
            case .success(let localities):
                self?.localities = localities
                
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if closest != nil {
                    newObservation?.locality = closest
                    
                    DispatchQueue.main.async {
                        if let currentCell = collectionView?.visibleCells.first as? ObservationLocationCell, let locationManager = locationManager, let newObservation = newObservation  {
                            currentCell.configureCell(locationManager: locationManager, newObservation: newObservation, localities: localities)
                        } else {
                            ELNotificationView.appNotification(style: .Custom(color: UIColor.appSecondaryColour(), image: #imageLiteral(resourceName: "Icons_Map_LocalityPin_Normal")), primaryText: NSLocalizedString("addObservationVC_localityFound_title", comment: ""), secondaryText: String.localizedStringWithFormat(NSLocalizedString("addObservationVC_localityFound_message", comment: ""), closest!.name, location.coordinate.longitude.rounded(toPlaces: 2), location.coordinate.latitude.rounded(toPlaces: 2), location.horizontalAccuracy.rounded(toPlaces: 2)), location: .bottom)
                                .show(animationType: .fromBottom, onViewController: self)
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    ELNotificationView.appNotification(style: .error(actions: nil), primaryText: NSLocalizedString("addObservationVC_localityFoundError_title", comment: ""), secondaryText: error.message, location: .bottom)
                        .show(animationType: .fromBottom, onViewController: self)
                }
            }
        }
    }
}

extension AddObservationVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ObservationCategories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch ObservationCategories.allCases[indexPath.row]{
        case .Species:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationSpecieCell", for: indexPath) as? ObservationSpecieCell else {fatalError()}
            cell.delegate = self
            cell.configureCell(newObservation: newObservation)
            return cell
        case .Location:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationLocationCell", for: indexPath) as? ObservationLocationCell else {fatalError()}
            cell.delegate = self
            return cell
        case .Details:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationDetailsCell", for: indexPath) as? ObservationDetailsCell else {fatalError()}
            cell.configure(newObservation: newObservation, delegate: self)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ObservationLocationCell {
            cell.configureCell(locationManager: locationManager, newObservation: newObservation, localities: localities)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        categoryView.moveSelector(toCellAtIndexPath: IndexPath(row: Int(ceil(collectionView.contentOffset.x/collectionView.bounds.size.width)), section: 0))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AddObservationVC: NavigationDelegate {
    
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
}
