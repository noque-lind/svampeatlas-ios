//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

enum DetailsContent {
    case mushroomWithID(taxonID: Int)
    case mushroom(mushroom : Mushroom, session: Session?, takesSelection: (selected: Bool, handler: ((_ selected: Bool) -> ()))?)
    case observation(observation: Observation, showSpeciesView: Bool, session: Session?)
}

class DetailsViewController: UIViewController {
    
    private lazy var spinner: Spinner = {
       let spinner = Spinner()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private lazy var imagesCollectionView: ImagesCollectionView = {
        let collectionView = ImagesCollectionView(imageContentMode: UIView.ContentMode.scaleAspectFill)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configureTimer()
        return collectionView
    }()
    
    private lazy var elNavigationBar: ELNavigationBar = {
       let view = ELNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var scrollView: AppScrollView?
    
    private lazy var selectButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appGreen()
        view.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        view.layer.shadowOpacity = 0.4
        
        let button: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            
            switch self.takesSelection!.selected {
            case true:
                button.setTitle("Fravælg", for: [])
                button.backgroundColor = UIColor.appRed()
                view.backgroundColor = UIColor.appRed()
            case false:
                button.setTitle("Vælg", for: [])
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
    
    let interactor = showImageAnimationInteractor()
    
    var images: [Image]?
    var takesSelection: (selected: Bool, handler: ((_ selected: Bool) -> ()))?
    
    init(detailsContent: DetailsContent) {
        self.detailsContent = detailsContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            elNavigationBar.minHeight = navigationBarFrame.maxY
            additionalSafeAreaInsets = UIEdgeInsets(top: -navigationBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
            
            if scrollView?.contentInset.top != elNavigationBar.maxHeight {
                scrollView?.contentInset.top = elNavigationBar.maxHeight
                scrollView?.scrollIndicatorInsets.top = elNavigationBar.maxHeight
                scrollView?.contentInset.bottom = view.safeAreaInsets.bottom
                scrollView?.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
            }
        }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = nil
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = nil
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = nil
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = nil
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        self.eLRevealViewController()?.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if images != nil {
            imagesCollectionView.invalidate()
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        super.viewDidDisappear(animated)
    }
    
    
    deinit {
        debugPrint("DetailsViewController was deinited correctly")
    }
    
    private func prepareView() {
        spinner.addTo(view: view)
        spinner.start()
        
        
        view.backgroundColor = UIColor.appSecondaryColour()
        
        
        switch detailsContent {
        case .mushroom(mushroom: let mushroom, let session, let takesSelection):
            
            let scrollView: MushroomDetailsScrollView = {
                let view = MushroomDetailsScrollView(session: session)
                view.configure(mushroom)
                view.customDelegate = self
                view.delegate = self
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.scrollView = scrollView
            self.takesSelection = takesSelection
            self.images = mushroom.images
            elNavigationBar.setTitle(title: mushroom.danishName ?? mushroom.fullName)
            setupView()
            
        case .observation(observation: let observation, let showSpeciesView, let session):
            
            let scrollView: ObservationDetailsScrollView = {
                let view = ObservationDetailsScrollView(session: session)
                view.configure(withObservation: observation, showSpeciesView: showSpeciesView)
                view.customDelegate = self
                view.delegate = self
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            self.scrollView = scrollView
            self.images = observation.images
            elNavigationBar.setTitle(title: "Fund af: \(observation.speciesProperties.name)")
            setupView()
            
            
        case .mushroomWithID(taxonID: let taxonID):
            DataService.instance.getMushroom(withID: taxonID) { [weak self] (result) in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .Error(_):
                        return
                    case .Success(let mushroom):
                        let scrollView: MushroomDetailsScrollView = {
                            let view = MushroomDetailsScrollView(session: nil)
                            view.configure(mushroom)
                            view.customDelegate = self
                            view.delegate = self
                            view.translatesAutoresizingMaskIntoConstraints = false
                            return view
                        }()
                        
                        self?.scrollView = scrollView
                        self?.images = mushroom.images
                        self?.elNavigationBar.setTitle(title: mushroom.danishName ?? mushroom.fullName)
                        self?.setupView()
                    }
                }
            }
        }
    }
    
    private func setupView() {
        spinner.stop()
        guard let scrollView = scrollView else {return}
        view.backgroundColor = UIColor.appSecondaryColour()
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
       
        if takesSelection != nil {
            view.addSubview(selectButton)
            selectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            selectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: 0).isActive = true
        } else {
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        view.addSubview(elNavigationBar)
        elNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        elNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        elNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        if let images = images {
            elNavigationBar.setContentView(view: imagesCollectionView, ignoreSafeAreaLayoutGuide: true, maxHeight: 300)
            scrollView.contentInset.top = elNavigationBar.maxHeight
            scrollView.scrollIndicatorInsets.top = elNavigationBar.maxHeight
            imagesCollectionView.configure(images: images)
        }
    }
    
    @objc private func selectButtonPressed() {
        guard let takesSelection = takesSelection else {return}
        takesSelection.handler(!takesSelection.selected)
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let appBarAdjustedOffset = scrollView.contentOffset.y + elNavigationBar.maxHeight
        let percent = 1 - (appBarAdjustedOffset / elNavigationBar.maxHeight)
        
        print(percent)
        elNavigationBar.setPercentExpanded(percent)
    
    }
    
//    private func setPosition(scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > -(elNavigationBar.maxHeight / 2) && scrollView.contentOffset.y < -elNavigationBar.minHeight {
//            scrollView.setContentOffset(CGPoint(x: 0.0, y: -elNavigationBar.minHeight) , animated: true)
//        } else if scrollView.contentOffset.y < -(elNavigationBar.maxHeight / 2) && scrollView.contentOffset.y < -elNavigationBar.minHeight {
//            scrollView.setContentOffset(CGPoint(x: 0.0, y: -elNavigationBar.maxHeight), animated: true)
//        }
//        }
//
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            setPosition(scrollView: scrollView)
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        setPosition(scrollView: scrollView)
//    }
}



extension DetailsViewController: ELRevealViewControllerDelegate, UIGestureRecognizerDelegate {
    func isAllowedToPushMenu() -> Bool? {
        return false
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

extension DetailsViewController: ImagesCollectionViewDelegate {
    func didSelectImage(atIndexPath indexPath: IndexPath) {
        let photoVC = ImageVC(images: images!, selectedIndexPath: indexPath)
        photoVC.transitioningDelegate = self
        photoVC.interactor = interactor
        present(photoVC, animated: true, completion: nil)
    }
}

extension DetailsViewController: NavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
