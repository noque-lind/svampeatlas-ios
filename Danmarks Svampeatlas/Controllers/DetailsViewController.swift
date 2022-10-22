//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import MapKit
import Then
import UIKit

enum DetailsContent {
    case mushroomWithID(taxonID: Int)
    case mushroom(mushroom: Mushroom)
    case observation(observation: Observation, showSpeciesView: Bool)
    case observationWithID(observationID: Int, showSpeciesView: Bool)
}

class DetailsViewController: UIViewController {
    
    enum Item {
        case observationHeader(observation: Observation)
        case mushroomHeader(mushroom: Mushroom)
        case text(text: String)
        case informationView(information: [(String, String)])
        case observation(observation: Observation)
        case heatMap(userRegion: MKCoordinateRegion, observations: [Observation])
        case observationLocation(observation: Observation)
        case comment(comment: Comment)
        case addComment(session: Session)
        case mushroom(mushroom: Mushroom)
    }
    
    private lazy var tableView = ELTableView<Item, CellProvider>.build(provider: CellProvider().then({$0.delegate = self})).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .none
        $0.scrollDelegate = self
        $0.didSelectItem.handleEvent { [weak self] (item, _) in
            switch item {
            case .mushroom(mushroom: let mushroom):
                self?.navigationController?.pushViewController(DetailsViewController.init(detailsContent: .mushroom(mushroom: mushroom), session: self?.session), animated: true)
            case .observation(observation: let observation):
                self?.navigationController?.pushViewController(DetailsViewController.init(detailsContent: .observation(observation: observation, showSpeciesView: false), session: self?.session), animated: true)
            case .observationLocation(observation: let observation):
                guard let latitude = observation.coordinates.last, let longitude = observation.coordinates.first else {return}
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let mapVC = MapVC()
                mapVC.mapView.addLocationAnnotation(location: coordinate)
                mapVC.mapView.setRegion(center: coordinate, zoomMetres: 50000)
                self?.navigationController?.pushViewController(mapVC, animated: true)
            default: return
            }
        }
    })
    
    private lazy var imagesCollectionView: ImagesCollectionView = {
        let collectionView = ImagesCollectionView(imageContentMode: UIView.ContentMode.scaleAspectFill)
        
        collectionView.didSelectImage = { [unowned self] indexPath in
            let photoVC = ImageVC(images: self.images!, selectedIndexPath: indexPath)
            photoVC.transitioningDelegate = self
            photoVC.modalPresentationStyle = .fullScreen
            photoVC.interactor = self.interactor
            self.present(photoVC, animated: true, completion: nil)
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configureTimer()
        return collectionView
    }()
    
    private lazy var elNavigationBar: ELNavigationBar = {
        let view = ELNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var viewModel: DetailsViewControllerViewModel = {
        let vm: DetailsViewControllerViewModel
        
        switch detailsContent {
        case .mushroom(mushroom: let mushroom):
            vm = .init(mushroomID: mushroom.id)
        case .observation(observation: let observation, showSpeciesView: let showSpeciesView):
            vm = .init(observation: observation, showSpecies: showSpeciesView)
        case .mushroomWithID(taxonID: let id):
            vm = .init(mushroomID: id)
        case .observationWithID(observationID: let id, showSpeciesView: let showSpeciesView):
            vm = .init(observationID: id, showSpecies: showSpeciesView)
        }
        
        return vm
    }()
    
    private lazy var selectButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appGreen()
        view.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        view.layer.shadowOpacity = 0.4
        
        let button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(self.takesSelection!.title, for: [])
            
            switch self.takesSelection!.selected {
            case true:
                button.backgroundColor = UIColor.appRed()
                view.backgroundColor = UIColor.appRed()
            case false:
                button.backgroundColor = UIColor.appGreen()
                view.backgroundColor = UIColor.appGreen()
            }
            
            button.setTitleColor(UIColor.appWhite(), for: [])
            button.titleLabel?.font = UIFont.appTitle()
            button.addTarget(self, action: #selector(selectButtonPressed), for: .touchUpInside)
            return button
        }()
        
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        return view
    }()
    
    private let detailsContent: DetailsContent
    private var viewDidLayout: Bool = false
    private var session: Session?
    private var takesSelection: (selected: Bool, title: String, handler: ((_ selected: Bool) -> Void))?
    
    let interactor = showImageAnimationInteractor()
    
    var images: [Image]? {
        didSet {
            if let images = images {
                elNavigationBar.setContentView(view: imagesCollectionView, ignoreSafeAreaLayoutGuide: true, maxHeight: 300)
                tableView.contentInset.top = elNavigationBar.maxHeight
                imagesCollectionView.configure(images: images)
            }
        }
    }
    
    init(detailsContent: DetailsContent, session: Session?, takesSelection: (selected: Bool, title: String, handler: ((_ selected: Bool) -> Void))? = nil) {
        self.session = session
        self.takesSelection = takesSelection
        self.detailsContent = detailsContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            if additionalSafeAreaInsets != UIEdgeInsets(top: -navigationBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0) {
                additionalSafeAreaInsets = UIEdgeInsets(top: -navigationBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
                elNavigationBar.minHeight = navigationBarFrame.maxY
            }
            
            if tableView.contentInset.top != elNavigationBar.maxHeight {
                tableView.contentInset.top = elNavigationBar.maxHeight
                tableView.contentInset.bottom = view.safeAreaInsets.bottom
                tableView.performUpdates { (updater) in
                    updater.scrollToTop(animated: false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        prepareView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.appConfiguration(translucent: true)
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if images != nil {
            imagesCollectionView.invalidate()
        }
    }
    
    deinit {
        debugPrint("DetailsViewController was deinited correctly")
    }
    
    private func prepareView() {
        switch detailsContent {
        case .observation, .observationWithID:
            setupAsObservationDetails()
        case .mushroom, .mushroomWithID:
            setupAsMushroomDetails()
        }
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        view.do({
            $0.addSubview(tableView)
            $0.addSubview(elNavigationBar)
        })
        tableView.do({
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        })
        
        if takesSelection != nil {
            view.addSubview(selectButton)
            selectButton.do({
                $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
            })
            tableView.bottomAnchor.constraint(equalTo: selectButton.topAnchor).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        elNavigationBar.do({
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        })
    }
    
    private func setupAsObservationDetails() {
        viewModel.observation.observe { [weak self] (state) in
            switch state {
            case .loading:
                self?.tableView.setSections(sections: [.init(title: nil, state: .loading)])
            case .error(error: let error, handler: let handler):
                self?.tableView.setSections(sections: [.init(title: nil, state: .error(error: error, handler: handler))])
            case .items(item: let observation):
                DispatchQueue.main.async {
                    self?.images = observation.images
                    self?.elNavigationBar.setTitle(title: String.localizedStringWithFormat(NSLocalizedString("detailsVC_observationTitle", comment: ""), observation.determination.name))
                }
                
                var sections: [ELKit.Section<Item>] = [.init(title: nil, state: .items(items: [.observationHeader(observation: observation)]))]
                if let notes = observation.note, notes != "" {
                    sections.append(.init(title: NSLocalizedString("observationDetailsScrollView_notes", comment: ""), state: .items(items: [.text(text: notes)])))
                }
                
                if let ecologyNote = observation.ecologyNote, ecologyNote != "" {
                    sections.append(.init(title: NSLocalizedString("observationDetailsScrollView_ecologyNotes", comment: ""), state: .items(items: [.text(text: ecologyNote)])))
                }
                
                var informationArray = [(String, String)]()
                if let substrate = observation.substrate {
                    informationArray.append((NSLocalizedString("observationDetailsScrollView_substrate", comment: ""), substrate.name))
                }
                
                if let vegetationType = observation.vegetationType {
                    informationArray.append((NSLocalizedString("observationDetailsScrollView_vegetationType", comment: ""), vegetationType.name))
                }
                
                sections.append(.init(title: NSLocalizedString("appScrollView_informationHeaderTitle", comment: ""), state: .items(items: [.informationView(information: informationArray)])))
                sections.append(.init(title: NSLocalizedString("observationDetailsScrollView_location", comment: ""), state: .items(items: [.observationLocation(observation: observation)])))
                
                let speciesSection = sections.appendAndGive(.init(title: NSLocalizedString("observationDetailsScrollView_species", comment: ""), state: .empty))
                let commentsSection = sections.appendAndGive(.init(title: NSLocalizedString("observationDetailsScrollView_comments", comment: ""), state: .empty))
                
                if let session = self?.session {
                    sections.append(.init(title: nil, state: .items(items: [.addComment(session: session)])))
                }
                
                self?.tableView.setSections(sections: sections)
                
                self?.viewModel.mushroom.observe(listener: { (state) in
                    self?.tableView.performUpdates(updates: { (updater) in
                        switch state {
                        case .loading: speciesSection.setState(state: .loading)
                        case .items(item: let mushroom): speciesSection.setState(state: .items(items: [.mushroom(mushroom: mushroom)]))
                        case .error(error: let error, handler: let handler): speciesSection.setState(state: .error(error: error, handler: handler))
                        default: return
                        }
                        updater.updateSection(section: speciesSection)
                    })
                })
                
                self?.viewModel.observationComments.observe { (state) in
                    self?.tableView.performUpdates(updates: { (updater) in
                        switch state {
                        case .error(error: let error, handler: let handler):
                            commentsSection.setState(state: .error(error: error, handler: handler))
                        case .items(item: let items):
                            commentsSection.setState(state: .items(items: items.map({Item.comment(comment: $0)})))
                        case .loading:
                            commentsSection.setState(state: .loading)
                        default: return
                        }
                        updater.updateSection(section: commentsSection)
                    })
                }
            case .empty: return
            }
        }
    }
    
    private func setupAsMushroomDetails() {
        viewModel.mushroom.observe { [weak self] (state) in
            switch state {
            case .empty: return
            case .error(error: let error, handler: let handler):
                self?.tableView.setSections(sections: [.init(title: nil, state: .error(error: error, handler: handler))])
            case .loading:
                self?.tableView.setSections(sections: [.init(title: nil, state: .loading)])
            case .items(item: let mushroom):
                DispatchQueue.main.async {
                    self?.elNavigationBar.setTitle(title: mushroom.localizedName ?? mushroom.fullName)
                    self?.images = mushroom.images
                }
                
                var sections: [ELKit.Section<Item>] = [.init(title: nil, state: .items(items: [.mushroomHeader(mushroom: mushroom)]))]
                
                if let description = mushroom.attributes?.description, description != "" {
                    sections.append(.init(title: NSLocalizedString("mushroomDetailsScrollView_description", comment: ""), state: .items(items: [.text(text: description)])))
                }
                
                if let eatability = mushroom.attributes?.eatability, eatability != "" {
                    sections.append(.init(title: NSLocalizedString("mushroomDetailsScrollView_eatability", comment: ""), state: .items(items: [.text(text: eatability)])))
                }
                
                if let similarities = mushroom.attributes?.similarities, similarities != "" {
                    sections.append(.init(title: NSLocalizedString("mushroomDetailsScrollView_similarities", comment: ""), state: .items(items: [.text(text: similarities)])))
                }
                
                if let validationNote = mushroom.attributes?.tipsForValidation, validationNote != "" {
                    sections.append(.init(title: NSLocalizedString("mushroomDetailsScrollView_validationTips", comment: ""), state: .items(items: [.text(text: validationNote)])))
                }
                
                var informationArray = [(String, String)]()
                if let totalObservations = mushroom.statistics?.acceptedCount {
                    informationArray.append((NSLocalizedString("mushroomDetailsScrollView_acceptedRecords", comment: ""), "\(totalObservations)"))
                }
                
                if let latestAcceptedRecord = mushroom.statistics?.lastAcceptedRecord {
                    informationArray.append((NSLocalizedString("mushroomDetailsScrollView_latestAcceptedRecord", comment: ""), Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.long) ?? ""))
                }
                
                if let updatedAt = mushroom.updatedAt {
                    informationArray.append((NSLocalizedString("mushroomDetailsScrollView_latestUpdated", comment: ""), Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
                }
                
                sections.append(.init(title: NSLocalizedString("appScrollView_informationHeaderTitle", comment: ""), state: .items(items: [.informationView(information: informationArray)])))
                
                let nearbyObservationsSection = ELKit.Section<Item>.init(title: NSLocalizedString("mushroomDetailsScrollView_heatMap", comment: ""), state: .empty)
                sections.append(nearbyObservationsSection)
                
                let observationSection = ELKit.Section<Item>.init(title: NSLocalizedString("mushroomDetailsScrollView_latestObservations", comment: ""), state: .loading)
                
                sections.append(observationSection)
                
                self?.tableView.setSections(sections: sections)
                
                self?.viewModel.relatedObservations.observe(listener: { (state) in
                    self?.tableView.performUpdates(updates: { (updater) in
                        switch state {
                        case .loading: observationSection.setState(state: .loading)
                        case .items(items: let observations): observationSection.setState(state: .items(items: observations.map({Item.observation(observation: $0)})))
                        case .error(error: let error, handler: let handler):
                            observationSection.setState(state: .error(error: error, handler: handler))
                        case .empty: observationSection.setState(state: .empty)
                        }
                        
                        updater.updateSection(section: observationSection)
                    })
                })
                
                self?.viewModel.userRegion.observe(listener: { (state) in
                    self?.tableView.performUpdates(updates: { (updater) in
                        switch state {
                        case .empty: return
                        case .loading: nearbyObservationsSection.setState(state: .loading)
                        case .error(error: let error, handler: let handler): nearbyObservationsSection.setState(state: .error(error: error, handler: handler))
                        case .items(item: let region):
                            
                            self?.viewModel.nearbyObservations.observe(listener: { (state) in
                                self?.tableView.performUpdates(updates: { (updater) in
                                    switch state {
                                    case .empty: return
                                    case .loading: return
                                    case .error(error: let error, handler: let handler): nearbyObservationsSection.setState(state: .error(error: error, handler: handler))
                                    case .items(item: let observations):
                                        nearbyObservationsSection.setState(state: .items(items: [.heatMap(userRegion: region, observations: observations)]))
                                    }
                                    
                                    updater.updateSection(section: nearbyObservationsSection)
                                })
                            })
                        }
                        
                        updater.updateSection(section: nearbyObservationsSection)
                    })
                })
            }
        }
    }
    
    @objc private func selectButtonPressed() {
        guard let takesSelection = takesSelection else {return}
        self.navigationController?.popViewController(animated: true)
        takesSelection.handler(!takesSelection.selected)
    }
}

extension DetailsViewController: ELTableViewNavigationBarConnector {
    func tableViewDidScroll(_ tableView: UIScrollView) {
        let appBarAdjustedOffset = tableView.contentOffset.y + elNavigationBar.maxHeight
        let percent = 1 - (appBarAdjustedOffset / elNavigationBar.maxHeight)
        elNavigationBar.setPercentExpanded(percent)
    }
}

extension DetailsViewController: ELRevealViewControllerDelegate, UIGestureRecognizerDelegate {
    func isAllowedToPushMenu() -> Bool? {
        return true
    }
}

extension DetailsViewController: UIViewControllerTransitioningDelegate {
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.hasStarted {
            return interactor
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShowImageAnimationController(isBeingPresented: false, imageFrame: CGRect.zero)
    }
}

extension DetailsViewController: CellProviderDelegate {
    func moreButtonPressed() {
        func addReportContentButton(_ alertController: UIAlertController, observationID: Int) {
            alertController.addAction(.init(title: NSLocalizedString("observationDetailsScrollView_rapportContent_title", comment: ""), style: .destructive, handler: { (_) in
                UIAlertController(title: NSLocalizedString("observationDetailsScrollView_rapportContent_title", comment: ""), message: NSLocalizedString("observationDetailsScrollView_rapportContent_message", comment: ""), preferredStyle: .alert)
                    .then({ vc in
                        vc.addTextField { (textField) in
                            textField.placeholder = NSLocalizedString("observationDetailsScrollView_rapportContent_placeholder", comment: "")
                            textField.font = .appPrimary()
                        }
                        
                        vc.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak self] (_) in
                            guard let comment = vc.textFields?.first?.text else {return}
                            self?.session?.reportOffensiveContent(observationID: observationID, comment: comment, completion: {
                                DispatchQueue.main.async {
                                    let notification = ELNotificationView.appNotification(style: .success, primaryText: NSLocalizedString("observationDetailsScrollView_rapportContent_thankYou_title", comment: ""), secondaryText: NSLocalizedString("observationDetailsScrollView_rapportContent_thankYou_message", comment: ""), location: .bottom)
                                    notification.show(animationType: .zoom)
                                }
                            })
                        }))
                        vc.addAction(UIAlertAction(title: NSLocalizedString("observationDetailsScrollView_rapportContent_abort", comment: ""), style: .cancel, handler: nil))
                        
                    })
                    .do({
                        self.present($0, animated: true, completion: nil)
                    })
            }))

        }
        
        switch viewModel.observation.value {
        case .items(item: let observation):
            let actionVC = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("observation_id", comment: ""), observation.id), message: NSLocalizedString("common_twoChoices", comment: ""), preferredStyle: .actionSheet).then({
                if let session = session {
                    if observation.isEditable(user: session.user) {
                        $0.addAction(.init(title: NSLocalizedString("action_editObservation", comment: ""), style: .default, handler: { [weak self] (_) in
                            AddObservationVC(type: .edit(observationID: observation.id), session: session).do({
                                self?.navigationController?.pushViewController($0, animated: true)
                            })
                        }))
                    } else {
                        addReportContentButton($0, observationID: observation.id)
                    }
                    
                    if observation.isDeleteable(user: session.user) {
                        $0.addAction(.init(title: NSLocalizedString("action_deleteObservation", comment: ""), style: .destructive, handler: { [weak self] (_) in
                            Spinner.start(onView: self?.view)
                            session.deleteObservation(id: observation.id) { (result) in
                                DispatchQueue.main.async {
                                    Spinner.stop()
                                }
                              
                                switch result {
                                case .failure(let error):
                                    DispatchQueue.main.async {
                                        ELNotificationView.appNotification(style: .error(actions: nil), primaryText: NSLocalizedString("error_cantDelete", comment: ""), secondaryText: error.message, location: .bottom).show(animationType: .fromBottom)
                                    }
                                case .success:
                                    DispatchQueue.main.async {
                                        self?.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: MyPageVC(session: session)), overrideTypeCheckIgnore: true)
                                    }
                                }
                              
                            }
                        }))
                        
                    }
                } else {
                    addReportContentButton($0, observationID: observation.id)
                    }
                
                $0.addAction(.init(title: NSLocalizedString("action_cancel", comment: ""), style: .cancel, handler: nil))
            })
            present(actionVC, animated: true, completion: nil)
        default: return
        }
    }
    
    func enterButtonPressed(withText: String) {
        switch viewModel.type {
        case .observation(id: let id):
            let newCommentSection = ELKit.Section<Item>.init(title: nil, state: .loading)
            
            tableView.performUpdates { (updater) in
                updater.addSection(section: newCommentSection, sectionIndex: self.tableView.sections.count - 1)
            }
            session?.uploadComment(observationID: id, comment: withText, completion: { [weak tableView] (result) in
                switch result {
                case .failure(let error):
                    newCommentSection.setState(state: .error(error: error, handler: nil))
                case .success(let comment):
                    newCommentSection.setState(state: .items(items: [.comment(comment: comment)]))
                }
                
                tableView?.performUpdates(updates: { (updates) in
                    updates.updateSection(section: newCommentSection)
                })
            })
        default: return
        }
    }
}
