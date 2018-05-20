//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var scrollView: MushroomDetailsScrollView!
    
    lazy var imagesCollectionView: ImagesCollectionView = {
       let collectionView = ImagesCollectionView(imageContentMode: UIViewContentMode.scaleAspectFill, defaultHeight: 300, navigationBarHeight: self.navigationController?.navigationBar.frame.maxY)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configure(images: mushroom.images!)
        collectionView.configureTimer()
        return collectionView
    }()
    
    private var speciesNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var navigationBarBackgroundView: UIView = {
       let view = UIView()
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        view.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        return view
    }()
    
    private lazy var customNavigationBarContentView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        
        let stackView: UIStackView = {
           let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.text = "4 billeder"
            
            stackView.addArrangedSubview(label)
            return stackView
        }()
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return view
    }()
    
    var mushroom: Mushroom!
    var imageScrollTimer: Timer!
    let interactor = showImageAnimationInteractor()
    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = true
        view.backgroundColor = UIColor.appSecondaryColour()
        super.viewDidLoad()
    
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        scrollView.configureScrollView(withMushroom: mushroom)
        
        
        view.addSubview(imagesCollectionView)
        imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(navigationBarBackgroundView)
        navigationBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationBarBackgroundView.heightAnchor.constraint(equalToConstant: (self.navigationController?.navigationBar.frame.maxY)!).isActive = true
        
        view.addSubview(customNavigationBarContentView)
        customNavigationBarContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
        customNavigationBarContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.origin.y)! + 4).isActive = true
        customNavigationBarContentView.bottomAnchor.constraint(equalTo: navigationBarBackgroundView.bottomAnchor, constant: -4).isActive = true
        customNavigationBarContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
        
                scrollViewContainerView.layer.cornerRadius = 20
                scrollViewContainerView.backgroundColor = UIColor.appSecondaryColour()
                scrollViewContainerView.layer.shadowOpacity = 0.4
                scrollViewContainerView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
            scrollViewContainerView.clipsToBounds = true
        
        scrollView.delegate = self
    }
    
    private func showCustomNavigationBarContent() {
        if customNavigationBarContentView.alpha == 0 {
            customNavigationBarContentView.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
            UIView.animate(withDuration: 0.2) {
                self.customNavigationBarContentView.transform = CGAffineTransform.identity
                self.customNavigationBarContentView.alpha = 1
            }
        }
    }
    
    private func hideCustomNavigationBarContent() {
        if customNavigationBarContentView.alpha == 1 {
            UIView.animate(withDuration: 0.2) {
                self.customNavigationBarContentView.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
                self.customNavigationBarContentView.alpha = 0
            }
        }
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
        navigationBarBackgroundView.alpha = alpha
        
        if alpha >= 1.0 {
            showCustomNavigationBarContent()
        } else {
            hideCustomNavigationBarContent()
        }
    }
}
