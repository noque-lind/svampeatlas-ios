//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum DetailsContent {
    case mushroom(mushroom : Mushroom)
    case observation(observation: Observation, showSpeciesView: Bool)
    case observationWithID(observationID: Int, showSpeciesView: Bool)
}

class DetailsViewController: UIViewController {
    
    private lazy var scrollView: DetailsScrollView = {
        var topInset = self.navigationController?.navigationBar.frame.maxY ?? 0
        if images != nil, images?.count != 0 {
            topInset = 300
        }
    
        let scrollView = DetailsScrollView()
        scrollView.contentInset = UIEdgeInsets.init(top: topInset, left: 0.0, bottom: scrollView.contentInset.bottom, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: topInset, left: 0.0, bottom: scrollView.contentInset.bottom, right: 0.0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.customDelegate = self
        return scrollView
    }()
    
    private lazy var imagesCollectionView: ImagesCollectionView = {
        let collectionView = ImagesCollectionView(imageContentMode: UIView.ContentMode.scaleAspectFill, defaultHeight: 300, navigationBarHeight: (self.navigationController?.navigationBar.frame.maxY))
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configureTimer()
        return collectionView
    }()
    
    private lazy var customNavigationBar: CustomNavigationBar = {
        let view = CustomNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let interactor = showImageAnimationInteractor()
    let detailsContent: DetailsContent
    var images: [Image]?
    private var hasBeenSetup = false
    
    init(detailsContent: DetailsContent) {
        self.detailsContent = detailsContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset = UIEdgeInsets.init(top: scrollView.contentInset.top, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollView.contentInset.top, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !hasBeenSetup {
            setupView()
            hasBeenSetup = true
        }
        self.eLRevealViewController()?.delegate = self
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        super.viewDidAppear(animated)
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
    
    private func setupView() {
        switch detailsContent {
        case .mushroom(mushroom: let mushroom):
            customNavigationBar.configureTitle(mushroom.danishName ?? mushroom.fullName)
            images = mushroom.images
            scrollView.configureScrollView(withMushroom: mushroom)
        case .observation(observation: let observation, let showSpeciesView):
            customNavigationBar.configureTitle("Fund af: \(observation.speciesProperties.name)")
            images = observation.images
            scrollView.configureScrollView(withObservation: observation, showSpeciesView: showSpeciesView)
        case .observationWithID(let observationID, let showSpeciesView):
            DataService.instance.getObservation(withID: observationID) { (appError, observation) in
                DispatchQueue.main.async {
                    guard let observation = observation else {return}
                    self.customNavigationBar.configureTitle("Fund af: \(observation.speciesProperties.name)")
                    self.images = observation.images
                    self.scrollView.configureScrollView(withObservation: observation, showSpeciesView: showSpeciesView)
                }
            }
        }
        
        view.backgroundColor = UIColor.appSecondaryColour()
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let images = images {
            view.addSubview(imagesCollectionView)
            imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            imagesCollectionView.configure(images: images)
        }
    
    
        view.addSubview(customNavigationBar)
        customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        customNavigationBar.heightAnchor.constraint(equalToConstant: (self.navigationController?.navigationBar.frame.maxY)!).isActive = true
        customNavigationBar.navigationBarOffset = self.navigationController?.navigationBar.frame.origin.y
        scrollView.delegate = self
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard images != nil else {return}
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollView == self.scrollView && images != nil {
            let minValue = (max(adjustedContentOffset, 0))
            imagesCollectionView.configureTransform(deltaValue: minValue)
            if minValue <= 0 {
                imagesCollectionView.configureHeightConstraint(deltaValue: adjustedContentOffset)
            }
    }
    }
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
        let photoVC = ImageVC(images: images!)
        photoVC.transitioningDelegate = self
        photoVC.interactor = interactor
        present(photoVC, animated: true, completion: nil)
    }
    
    func changeNavigationbarBackgroundViewAlpha(_ alpha: CGFloat) {
        customNavigationBar.changeAlpha(alpha)
    }
}

extension DetailsViewController: NavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        
    }
    
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
