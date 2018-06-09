//
//  ObservationVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationVC: UIViewController, ELRevealViewControllerDelegate {

    private var customNavigationBar: CustomNavigationBar = {
       let view = CustomNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var scrollView: CustomScrollView = {
       let scrollView = CustomScrollView(topInset: 300)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.configureScrollView(withObservation: observation)
        return scrollView
    }()
    
    lazy var imagesCollectionView: ImagesCollectionView = {
        let collectionView = ImagesCollectionView(imageContentMode: UIViewContentMode.scaleAspectFill, defaultHeight: 300, navigationBarHeight: self.navigationController?.navigationBar.frame.maxY)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.appPrimaryColour()
        
//        collectionView.configureTimer()
        return collectionView
    }()
    
    
    
    
    
    
    
    
    func isAllowedToPushMenu() -> Bool? {
        return false
    }
    
    private var observation: Observation

    init(observation: Observation) {
        self.observation = observation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        setupView()
        super.viewWillAppear(animated)
    }
    
    

    
    
    private func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(imagesCollectionView)
        imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        view.addSubview(customNavigationBar)
        customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        customNavigationBar.heightAnchor.constraint(equalToConstant: (self.navigationController?.navigationBar.frame.maxY)!).isActive = true
        customNavigationBar.navigationBarOffset = self.navigationController?.navigationBar.frame.origin.y
        
//        scrollView.contentSize = CGSize(width: view.frame.width, height: 700)
    }
    
    
    
    
    
}



extension ObservationVC: ImagesCollectionViewDelegate {
    func changeNavigationbarBackgroundViewAlpha(_ alpha: CGFloat) {
    
    }
    
    func didSelectImage(atIndexPath indexPath: IndexPath) {
        
    }
    
    
}
