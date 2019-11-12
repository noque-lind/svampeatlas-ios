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
    
    private lazy var menuButton: UIBarButtonItem = {
       
        let button = UIBarButtonItem(image:  #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    private lazy var uploadObservationButton: UIBarButtonItem = {
        
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_Upload"), style: .plain, target: self, action: #selector(beginObservationUpload))
        return button
    }()
    
    private lazy var observationImagesView: ObservationImagesView = {
        let view = ObservationImagesView(newObservation: newObservation)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var categoryView: CategoryView<ObservationCategories> = {
        let items = ObservationCategories.allCases.compactMap({Category<ObservationCategories>(type: $0, title: $0.rawValue)})
        let view = CategoryView<ObservationCategories>.init(categories: items, firstIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        view.categorySelected = { [unowned collectionView] category in
            guard let index = ObservationCategories.allCases.index(of: category) else {return}
            collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            view.endEditing(true)
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
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if newObservation.observationCoordinate == nil && newObservation.locality == nil {
            locationManager.start()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        observationImagesView.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Nyt fund"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    deinit {
        debugPrint("AddObservationVC was deinited")
    }
    
    private func setupView() {
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
        self.navigationItem.setRightBarButton(uploadObservationButton, animated: false)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
    }
        
    private func reset() {
        self.newObservation = NewObservation()
        self.observationImagesView.configure(newObservation: newObservation)
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        self.categoryView.moveSelector(toCellAtIndexPath: IndexPath.init(row: 0, section: 0))
        locationManager.start()
    }
    
    @objc private func beginObservationUpload() {
        switch newObservation.returnAsDictionary(user: session.user) {
        case .Success(let dict):
            Spinner.start(onView: self.navigationController?.view)
        
            session.uploadObservation(dict: dict, images: newObservation.images) { (result) in
                Spinner.stop()
                switch result {
                case .Success(let observationID):
                    DispatchQueue.main.async {
                        let notificationView = ELNotificationView.appNotification(style: .success, primaryText: "Dit fund er blevet oprettet", secondaryText: "ID: \(observationID)", location: .bottom)
                        notificationView.show(animationType: ELNotificationView.AnimationType.fromBottom, onViewController: self)
                        self.reset()
                    }
                    
                case .Error(let error):
                    DispatchQueue.main.async {
                        let notificationView = ELNotificationView.appNotification(style: .error, primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .bottom)
                        notificationView.show(animationType: ELNotificationView.AnimationType.fromBottom, onViewController: self)
                    }
                }
            }
        case .Error(let error):
            self.handleUncompleteObservation(newObservationError: error)
        }
    }
    
    
    
    
    private func handleUncompleteObservation(newObservationError error: NewObservation.Error) {
        var indexPath: IndexPath
        
        let notificationView = ELNotificationView(style: .error, attributes: ELNotificationView.Attributes.appAttributes())
    
        switch error {
        case .noMushroom:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Species)! , section: 0)
            
            notificationView.configure(primaryText: "Manglende information", secondaryText: "For at uploade en observation, skal du enten tilføje billeder, eller identificere en art.")
            
        case .noSubstrateGroup:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Details)! , section: 0)
            notificationView.configure(primaryText: "Manglende information", secondaryText: "Du skal både opgive substrat og vegetationstype for din observation")
        case .noVegetationType:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Details)! , section: 0)
            
            notificationView.configure(primaryText: "Manglende information", secondaryText: "Du skal både opgive substrat og vegetationstype for din observation")
        case .noLocality:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Location)! , section: 0)
            notificationView.configure(primaryText: "Hvor er du?", secondaryText: "Du skal hjælpe med at fortælle hvad du er i nærheden af.")
        case .noCoordinates:
            indexPath = IndexPath(row: ObservationCategories.allCases.firstIndex(of: .Location)!, section: 0)
            notificationView.configure(primaryText: "Ingen coordinater", secondaryText: "Appen kunne ikke finde dine koordinater, men du kan sætte dem selv.")
        }
        
        notificationView.show(animationType: .fromBottom ,queuePosition: .front)
        categoryView.moveSelector(toCellAtIndexPath: indexPath)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
}


extension AddObservationVC: LocationManagerDelegate {
    func locationRetrieved(location: CLLocation) {
        newObservation.observationCoordinate = location
        
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { (result) in
            switch result {
            case .Success(let localities):
                self.localities = localities
                
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if closest != nil {
                    self.newObservation.locality = closest
                    
                    DispatchQueue.main.async {
                        if let currentCell = self.collectionView.visibleCells.first as? ObservationLocationCell {
                            currentCell.configureCell(locationManager: self.locationManager, newObservation: self.newObservation, localities: localities)
                        } else {
                            let notificationView = ELNotificationView.appNotification(style: .Custom(color: UIColor.appPrimaryColour(), image: #imageLiteral(resourceName: "Icons_Map_LocalityPin_Normal")), primaryText: "Lokation bestemt", secondaryText: "Du er tættest på: \(closest!.name)", location: .bottom)
                            notificationView.show(animationType: .fade, queuePosition: .back, onViewController: self)
                        }
                    }
                    
                }
                
            case .Error(let error):
                DispatchQueue.main.async {
                    let notificationView = ELNotificationView.appNotification(style: .error, primaryText: "Nærmeste lokalitet kunne ikke findes, prøv igen.", secondaryText: error.errorDescription, location: .bottom)
                    notificationView.show(animationType: .fade, queuePosition: .back, onViewController: self)
                }
            }
        }
    }
    
    func locationInaccessible(error: LocationManagerError) {
        print(error)
    }
    
    func userDeniedPermissions() {
        DispatchQueue.main.async {
            let notificationView = ELNotificationView.appNotification(style: .error, primaryText: "Kunne ikke hente din lokation", secondaryText: "Giv appen tilladelse i indstillinger.", location: .bottom)
            
            notificationView.onTap = {
                if let bundleId = Bundle.main.bundleIdentifier,
                    let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            notificationView.show(animationType: .fade, queuePosition: .back, onViewController: self)
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
            cell.configureCell(newObservation: newObservation)
            cell.delegate = self
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

extension AddObservationVC: ObservationImagesViewDelegate, NavigationDelegate {
    func shouldAnimateHeightChanged() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            self?.observationImagesView.invalidateLayout()
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }) { (_) in
        }
    }
    
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
}
