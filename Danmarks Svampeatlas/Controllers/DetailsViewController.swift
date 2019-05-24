//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum DetailsContent {
    case mushroom(mushroom : Mushroom, takesSelection: (selected: Bool, handler: ((_ selected: Bool) -> ()))?)
    case observation(observation: Observation, showSpeciesView: Bool, session: Session?)
}

class DetailsViewController: UIViewController {
    
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
            button.titleLabel?.font = UIFont.appHeader()
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
    
    override func viewWillLayoutSubviews() {
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            additionalSafeAreaInsets = UIEdgeInsets(top: -navigationBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
            print(navigationBarFrame.maxY)
            customNavigationBar.heightConstraint?.constant = navigationBarFrame.maxY
            scrollView?.contentInset = UIEdgeInsets(top: images != nil ? (300): navigationBarFrame.maxY, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
            scrollView?.scrollIndicatorInsets = UIEdgeInsets(top: images?.count != 0 ? (300 + 8): 8, left: 0.0, bottom: view.safeAreaInsets.bottom + 8, right: 0.0)
            
        }
        super.viewWillLayoutSubviews()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.eLRevealViewController()?.delegate = self
        self.navigationController?.navigationBar.isTranslucent = true
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
        case .mushroom(mushroom: let mushroom, let takesSelection):
            
            let scrollView: MushroomDetailsScrollView = {
                let view = MushroomDetailsScrollView()
                view.configureScrollView(withMushroom: mushroom)
                view.customDelegate = self
                view.delegate = self
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            
            self.scrollView = scrollView
            customNavigationBar.configureTitle(mushroom.danishName ?? mushroom.fullName)
            images = mushroom.images
            self.takesSelection = takesSelection
            
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
            customNavigationBar.configureTitle("Fund af: \(observation.speciesProperties.name)")
            images = observation.images
        }
        
        guard let scrollView = scrollView else {return}
        view.backgroundColor = UIColor.appSecondaryColour()
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
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
        
        scrollView.delegate = self
        
    }
    
    @objc private func selectButtonPressed() {
        guard let takesSelection = takesSelection else {return}
        takesSelection.handler(!takesSelection.selected)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard images != nil else {return}
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
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
