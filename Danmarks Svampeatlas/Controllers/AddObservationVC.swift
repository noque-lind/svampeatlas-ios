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
    
    private enum ObservationCategories: String, CaseIterable {
        case Species = "Art"
        case Details = "Detajler"
        case Location = "Lokalitet"
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
        
        view.imageDeleted = { [unowned newObservation] imageURL in
            newObservation.removeImage(imageURL: imageURL)
        }
        
        view.onAddImageButtonPressed = { [unowned self, unowned view, unowned newObservation] in
            let vc = CameraVC(cameraVCUsage: .imageCapture)
            vc.onImageCaptured = { imageURL in
                newObservation.appendImage(imageURL: imageURL)
                view.addImage(imageURL: imageURL)
                
                if let imageLocation = newObservation.returnImageLocationIfNecessary(imageURL: imageURL) {
                    self.handleImageLocation(imageLocation: imageLocation, alternativeLocation: nil)
                }
            }
            self.presentVC(UINavigationController(rootViewController: vc))
        }
        
        return view
    }()
    
    private lazy var categoryView: CategoryView<ObservationCategories> = {
        let items = ObservationCategories.allCases.compactMap({Category<ObservationCategories>(type: $0, title: $0.rawValue)})
        let view = CategoryView<ObservationCategories>.init(categories: items, firstIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        view.categorySelected = { [unowned collectionView, unowned self] category in
            guard let index = ObservationCategories.allCases.index(of: category) else {return}
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
        manager.delegate = self
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if newObservation.observationCoordinate == nil && newObservation.locality == nil {
            locationManager.start()
        }
    }
    
    deinit {
        debugPrint("AddObservationVC was deinited")
    }
    
    private func setupView() {
        title = "Nyt fund"
    
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
    }
        
    private func reset() {
        newObservation = NewObservation()
        configure()
        collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        locationManager.start()
    }
    
    @objc private func beginObservationUpload() {
        switch newObservation.returnAsDictionary(user: session.user) {
        case .Success(let dict):
            Spinner.start(onView: self.navigationController?.view)
        
            session.uploadObservation(dict: dict, imageURLS: newObservation.images) { [weak self] (result) in
                Spinner.stop()
                DispatchQueue.main.async {
                switch result {
                case .Success(let observationID):
                    ELNotificationView.appNotification(style: .success, primaryText: "Dit fund er blevet oprettet", secondaryText: "ID: \(observationID)", location: .bottom)
                        .show(animationType: .fromBottom, onViewController: self)
                case .Error(let error):
                    ELNotificationView.appNotification(style: .error(actions: nil), primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .bottom)
                        .show(animationType: .fromBottom, onViewController: self)
                }
                }
            }
        case .Error(let error):
            self.handleUncompleteObservation(newObservationError: error)
        }
    }
    
    private func handleUncompleteObservation(newObservationError error: NewObservation.Error) {
        var indexPath: IndexPath

        let notificationView = ELNotificationView(style: .error(actions: nil), attributes: ELNotificationView.Attributes.appAttributes())
        notificationView.configure(primaryText: error.errorTitle, secondaryText: error.errorDescription)
    
        switch error {
        case .noMushroom:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Species)! , section: 0)
        case .noSubstrateGroup, .noVegetationType:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Details)! , section: 0)
        case .noLocality, .noCoordinates:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Location)! , section: 0)
        }
        
        notificationView.show(animationType: .fromBottom ,queuePosition: .front, onViewController: self)
        categoryView.moveSelector(toCellAtIndexPath: indexPath)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
    
    private func handleImageLocation(imageLocation: CLLocation, alternativeLocation: CLLocation?) {
        ELNotificationView.appNotification(style: .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
        .positive("Ja, brug billedets placering", { [unowned newObservation, unowned self] in
            newObservation.observationCoordinate = imageLocation
            self.findLocality(location: imageLocation)
        }),
        .negative("Nej", { [unowned newObservation, unowned self] in
            if let alternativeLocation = alternativeLocation {
                newObservation.observationCoordinate = alternativeLocation
                           self.findLocality(location: alternativeLocation)
            }
        })]), primaryText: "Forslag til placering", secondaryText: "Et tilføjet billede lader til at være blevet taget over 500 meter væk fra din nuværende placering. Vil du bruge billedets GPS-information i stedet for din nuværende placering?", location: .bottom)
        .show(animationType: .fromBottom, onViewController: self)
    }
}

extension AddObservationVC: LocationManagerDelegate {
    func locationInaccessible(error: LocationManager.LocationManagerError) {
        let notif: ELNotificationView
        
        switch error.recoveryAction {
        case .openSettings:
            notif = ELNotificationView.appNotification(style: .error(actions: [
                .neutral(error.recoveryAction?.rawValue, {
                    UIApplication.openSettings()
                })
            ]),location: .bottom)
            
        case .tryAgain:
            notif = ELNotificationView.appNotification(style: .error(actions: [
                .neutral(error.recoveryAction?.rawValue, { [unowned locationManager] in
                    locationManager.start()
                })
            ]), location: .bottom)
        
        default:
            notif = ELNotificationView.appNotification(style: .error(actions: nil), location: .bottom)
        }
        
        notif.configure(primaryText: error.errorTitle, secondaryText: error.errorDescription)
        notif.show(animationType: .fromBottom)
    }
    
    private func findLocality(location: CLLocation) {
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { [weak self, weak locationManager, weak newObservation, weak collectionView] result in
            switch result {
            case .Success(let localities):
                self?.localities = localities
                
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if closest != nil {
                    newObservation?.locality = closest
                    
                    DispatchQueue.main.async {
                        if let currentCell = collectionView?.visibleCells.first as? ObservationLocationCell, let locationManager = locationManager, let newObservation = newObservation  {
                            currentCell.configureCell(locationManager: locationManager, newObservation: newObservation, localities: localities)
                        } else {
                            ELNotificationView.appNotification(style: .Custom(color: UIColor.appSecondaryColour(), image: #imageLiteral(resourceName: "Icons_Map_LocalityPin_Normal")), primaryText: "Fundets placering er blevet bestemt", secondaryText: "Navn: \(closest!.name) \nKoordinater: \(location.coordinate.latitude.rounded(toPlaces: 2)), \(location.coordinate.longitude.rounded(toPlaces: 2))", location: .bottom)
                                .show(animationType: .fromBottom, onViewController: self)
                        }
                    }
                }
                
            case .Error(let error):
                DispatchQueue.main.async {
                    ELNotificationView.appNotification(style: .error(actions: nil), primaryText: "Nærmeste placering kunne ikke findes.", secondaryText: error.errorDescription, location: .bottom)
                        .show(animationType: .fromBottom, onViewController: self)
                }
            }
        }
    }
    
    func locationRetrieved(location: CLLocation) {
        if let imageLocation = newObservation.returnImageLocationIfNecessary(location: location) {
            handleImageLocation(imageLocation: imageLocation, alternativeLocation: location)
        } else {
            newObservation.observationCoordinate = location
            findLocality(location: location)
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
