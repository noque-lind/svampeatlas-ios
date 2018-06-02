//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    lazy var scrollView: CustomScrollView = {
        let scrollView = CustomScrollView(topInset: 300)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var imagesCollectionView: ImagesCollectionView = {
       let collectionView = ImagesCollectionView(imageContentMode: UIViewContentMode.scaleAspectFill, defaultHeight: 300, navigationBarHeight: self.navigationController?.navigationBar.frame.maxY)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configure(images: mushroom.images!)
        collectionView.configureTimer()
        return collectionView
    }()
    
    private lazy var customNavigationBar: CustomNavigationBar = {
        let view = CustomNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.spacing = 10
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Camera"), for: [])
        
       stackView.addArrangedSubview(button)
        
        if let count = mushroom.images?.count {
            let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.text = "\(count) billeder"
            stackView.addArrangedSubview(label)
        }
        
        view.configureContent(stackView: stackView, alignment: UIStackViewAlignment.center)
        return view
    }()

    
    var mushroom: Mushroom
    var imageScrollTimer: Timer!
    let interactor = showImageAnimationInteractor()
    
    
    init(mushroom: Mushroom) {
        self.mushroom = mushroom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        setupView()
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

   
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        imagesCollectionView.invalidate()
        super.viewDidDisappear(animated)
    }
    
    deinit {
        print("Deeinit called")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.configureScrollView(withMushroom: mushroom)
        
        
        view.addSubview(imagesCollectionView)
        imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
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
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollView == self.scrollView {
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
        let photoVC = ImageVC(images: mushroom.images!)
        photoVC.transitioningDelegate = self
        photoVC.interactor = interactor
        present(photoVC, animated: true, completion: nil)
    }
    
    func changeNavigationbarBackgroundViewAlpha(_ alpha: CGFloat) {
        customNavigationBar.changeAlpha(alpha)
    }
}
