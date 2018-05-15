//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var pageControl: ImagesPageControl!
    @IBOutlet weak var scrollViewContainerView: UIView!
    @IBOutlet weak var scrollView: MushroomDetailsScrollView!
    
     @IBOutlet weak var imageCollectionView: ImagesCollectionView!
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    var mushroom: Mushroom!
    var imageScrollTimer: Timer!
    let interactor = showImageAnimationInteractor()
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.appSecondaryColour()
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 11.0, *) {
//            imagesCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            
        }
        
        
        pageControl.delegate = self
        pageControl.dataSource = self
//        scrollView.delegate = self
        setupView()
        setupImageTimer()
        setupScrollView()
    }

    private func setupImageTimer() {
        imageScrollTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(handleImageTimer), userInfo: nil, repeats: true)
    }
    
    @objc func handleImageTimer() {
        pageControl.nextPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        imageScrollTimer.invalidate()
        super.viewDidDisappear(animated)
    }
    
    deinit {
        print("Deeinit called")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func setupView() {
                scrollViewContainerView.layer.cornerRadius = 20
                scrollViewContainerView.backgroundColor = UIColor.appSecondaryColour()
                scrollViewContainerView.layer.shadowOpacity = 0.4
                scrollViewContainerView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
            scrollViewContainerView.clipsToBounds = true
        imageCollectionView.setupHeightConstraint(defaultHeight: 200, navigationBarHeight: (self.navigationController?.navigationBar.frame.height)!)
        scrollView.delegate = self
        
        
    }
    
    func setupScrollView() {
//        scrollView.setupInsets(collectionViewHeight: imagesCollectionView.defaultHeightConstant)
        scrollView.configureScrollView(withMushroom: mushroom)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        imagesCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension DetailsViewController {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return mushroom.images!.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let photoVC = self.storyboard?.instantiateViewController(withIdentifier: "photoVC") as? PhotoVCViewController else {return}
//        photoVC.transitioningDelegate = self
//        photoVC.images = mushroom.images!
//        photoVC.interactor = interactor
//        present(photoVC, animated: true, completion: nil)
//    }
//
//
//
//
    
}

extension DetailsViewController: ImagesPageControlDataSource, ImagesPageControlDelegate{
    func numberOfPages() -> Int {
        return mushroom.images!.count
    }
    
    func didChangePage(toPage page: Int) {
        let indexPath = IndexPath(row: page, section: 0)
//        imagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollView == self.scrollView {
            let minValue = (max(adjustedContentOffset, 0))
            imageCollectionView.transform = CGAffineTransform(translationX: 0.0, y: -minValue)
            
            if minValue <= 0 {
                imageCollectionView.configureHeightConstraint(deltaValue: adjustedContentOffset)
            }
    }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.scrollView {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        imageScrollTimer.invalidate()
        setupImageTimer()
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


