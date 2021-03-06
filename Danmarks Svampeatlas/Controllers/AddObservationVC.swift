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
    
    enum Action {
        case new
        case edit(observationID: Int)
    }
    
    private enum ObservationCategories: CaseIterable, Equatable {
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
    
    private lazy var idLabel = UILabel().then({
        $0.font = .appMuted()
        $0.textColor = .appWhite()
    })
    
    private lazy var observationImagesView = ObservationImagesView().then({ view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isExpanded = !(viewModel.images.value.count == 0)
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
        
        view.imageDeleted = { [weak self] imageUrl in
            if !UserDefaultsHelper.hasSeenImageDeletionTip() {
                self?.present(TermsVC(terms: .deleteImageTip), animated: true, completion: nil)
                self?.viewModel.images.set(self?.viewModel.images.value ?? [])
                UserDefaultsHelper.setHasSeenImageDeletionTip()
            } else {
                self?.viewModel.removeImage(newObservationImage: imageUrl)
            }
        }
        
        view.onAddImageButtonPressed = { [weak self, weak viewModel] in
           CameraVC(cameraVCUsage: .imageCapture).then({
                $0.onImageCaptured = { imageURL in
                    viewModel?.addImage(newObservationImage: NewObservationImage(type: .new, url: imageURL))
                }
            })
           .do({
            self?.presentVC(UINavigationController(rootViewController: $0).then({$0.modalPresentationStyle = .fullScreen}))
           })
        }
    })
    
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
    
    private let action: Action
    private let viewModel: AddObservationViewModel
    
    init(type: Action, session: Session) {
        self.action = type
        self.viewModel = .init(action: type, session: session)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: AddObservationViewModel) {
        self.action = viewModel.action
        self.viewModel = viewModel
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
        setupViewModel()
        }
        
    private func setupView() {
        view.clipsToBounds = true
        view.backgroundColor = UIColor.appPrimaryColour()
        
        switch viewModel.action {
        case .new:
            title = NSLocalizedString("addObservationVC_title", comment: "")
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu)), animated: false)
        case .edit:
            self.navigationItem.titleView = UIStackView().then({
                $0.axis = .vertical
                $0.alignment = .center
                $0.addArrangedSubview(UILabel().then({
                    $0.font = .appTitle()
                    $0.textColor = .appWhite()
                    $0.text = NSLocalizedString("Edit observation", comment: "")
                }))
                
                $0.addArrangedSubview(idLabel)
            })
        }
        
        navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_Upload"), style: .plain, target: self, action: #selector(beginObservationUpload)), animated: false)
        
        let gradientView = GradientView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        view.do({
            $0.addSubview(gradientView)
            $0.addSubview(observationImagesView)
            $0.addSubview(categoryView)
            $0.addSubview(collectionView)
        })
        gradientView.do({
            $0.topAnchor.constraint(equalTo: observationImagesView.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        })
        observationImagesView.do({
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        })
        categoryView.do({
            $0.topAnchor.constraint(equalTo: observationImagesView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        })
        collectionView.do({
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        })
    }
    
    private func configure() {
        switch viewModel.action {
        case .edit(observationID: let id):
            idLabel.text = "ID: \(id)"
        case .new: return
            
        }
    }
    
    private func setupViewModel() {
        viewModel.setupState.observe { [weak self] (state) in
            DispatchQueue.main.async {
                switch state {
                case .empty: return
                case .error(error: let error, handler: let handler):
                    return
                case .loading: Spinner.start(onView: self?.view)
                case .items:
                    self?.collectionView.reloadData()
                    guard let type = self?.viewModel.action else {return}
                    switch type {
                    case .new:
                        self?.categoryView.moveSelector(toCellAtIndexPath: .init(row: 0, section: 0))
                        self?.collectionView.scrollToItem(at: .init(row: 0, section: 0), at: .left, animated: true)
                    case .edit:
                        self?.categoryView.moveSelector(toCellAtIndexPath: .init(row: 1, section: 0))
                        self?.collectionView.scrollToItem(at: .init(row: 1, section: 0), at: .left, animated: true)
                    }
                }
            }
        }
        
        viewModel.uploadState.observe { [weak self] (state) in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    Spinner.start(onView: self?.view)
                default: Spinner.stop()
                }
            }
        }
        
        viewModel.images.observe { [weak observationImagesView] (images) in
            DispatchQueue.main.async {
                observationImagesView?.configure(newObservationImages: images)
            }
        }
        
        viewModel.addedImage.handleEvent { [weak observationImagesView] (image) in
            DispatchQueue.main.async {
                observationImagesView?.addImage(newObservationImage: image)
            }
        }
        
        viewModel.removedImage.handleEvent { [weak observationImagesView] (index) in
            DispatchQueue.main.async {
                observationImagesView?.removeImage(index: index)
            }
        }
        
        viewModel.observationLocation.observe { [weak self] (state) in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: true)
                case .items(item: let location):
                    if let cell = self?.collectionView.visibleCells.first as? ObservationLocationCell {
                        cell.configureObservationLocation(location: location)
                    }
                    self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: false)
                    
                default: self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: false)
                  }
            }
        }
        
        viewModel.localities.observe { [weak self] (state) in
            DispatchQueue.main.async {
                switch state {
                case .loading: self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: true)
                case .items(item: let localities):
                    if let cell = self?.collectionView.visibleCells.first as? ObservationLocationCell {
                        cell.configureLocalities(localities: localities)
                    }
                    self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: false)
                default: self?.categoryView.setCategoryLoadingState(atIndex: ObservationCategories.allCases.firstIndex(of: .Location)!, loading: false)
                }
            }
        }
        
        viewModel.locality.observe { [weak self] (locality) in
            guard let locality = locality else {return}
            DispatchQueue.main.async {
                if let cell = self?.collectionView.visibleCells.first as? ObservationLocationCell {
                    cell.configureLocality(locality: locality)
                }
            }
        }
        
        viewModel.showNotification.handleEvent { [weak self, unowned viewModel] (value) in
            DispatchQueue.main.async {
                let notif = ELNotificationView.appNotification(style: value.1, primaryText: value.0.title, secondaryText: value.0.message, location: .bottom)
                
                switch value.0 {
                case .successfullUpload:
                    notif.show(animationType: .fromBottom, queuePosition: .front, onViewController: self)
                    viewModel.reset()
                case .editCompleted, .editWithError:
                    notif.show(animationType: .fromBottom, queuePosition: .front, onViewController: nil)
                    self?.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: MyPageVC(session: viewModel.session)))
                case .error, .localityError:
                    notif.show(animationType: .fromBottom, queuePosition: .front, onViewController: self)
                case .newObservationError(error: let error):
                    notif.show(animationType: .fromBottom, queuePosition: .front, onViewController: self)
                    switch error {
                    case .lowAccuracy, .noCoordinates, .noLocality:
                        self?.collectionView.scrollToItem(at: .init(row: ObservationCategories.allCases.firstIndex(of: .Location)!, section: 0), at: .left, animated: true)
                    case .noMushroom:
                        self?.collectionView.scrollToItem(at: .init(row: ObservationCategories.allCases.firstIndex(of: .Species)!, section: 0), at: .left, animated: true)
                    case .noSubstrateGroup, .noVegetationType:
                        self?.collectionView.scrollToItem(at: .init(row: ObservationCategories.allCases.firstIndex(of: .Details)!, section: 0), at: .left, animated: true)
                    }
                   
                case .foundLocationAndLocality:
                    if !(self?.collectionView.visibleCells.first is ObservationLocationCell) {
                        notif.show(animationType: .fromBottom, queuePosition: .back, onViewController: self)
                    }
                default:
                    notif.show(animationType: .fromBottom, queuePosition: .back, onViewController: self)
                }
            }
        }
    }
        
    private func reset() {
        configure()
        collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
    }
    
    @objc private func beginObservationUpload(overrideLowAccuracy: Bool = false) {
        viewModel.uploadObservation(action: action)
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
            cell.configureCell(viewModel: viewModel, action: viewModel.action)
            return cell
        case .Location:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationLocationCell", for: indexPath) as? ObservationLocationCell else {fatalError()}
            cell.delegate = self
            cell.viewModel = viewModel
            return cell
        case .Details:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationDetailsCell", for: indexPath) as? ObservationDetailsCell else {fatalError()}
            cell.configure(viewModel: viewModel, delegate: self)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ObservationLocationCell {
            viewModel.observationLocation.value.item?.do({
                cell.configureObservationLocation(location: $0)
            })
            
            viewModel.localities.value.item?.do({
                cell.configureLocalities(localities: $0)
            })
            
            if let locality = viewModel.locality.value {
                cell.configureLocality(locality: locality)
            }
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
