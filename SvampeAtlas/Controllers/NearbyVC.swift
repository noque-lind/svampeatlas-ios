//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NearbyVC: UIViewController {
    
    private var categoryView: CategoryView = {
        var view = CategoryView(categories: [Category.init(title: "Vis alle"), Category.init(title: "Giftige"), Category.init(title: "Spiselige"), Category.init(title: "Sjældne"), Category.init(title: "Med billeder")], firstIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var gradientView: GradientView = {
       let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapView: LocationBackground = {
        let view = LocationBackground()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
  
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(menuButtonPressed))
        return button
    }()
    
    private var hasAppeared = false

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryView.delegate = self
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        view.insertSubview(gradientView, at: 0)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(categoryView)
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        categoryView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    
        view.insertSubview(mapView, belowSubview: categoryView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
        setupNavigationController()
    }
    
    
    private func setupNavigationController() {
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "I nærheden"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appHeader()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc private func menuButtonPressed() {
        self.eLRevealViewController()?.toggleSideMenu()
    }
}

extension NearbyVC: CategoryViewDelegate {
    func categorySelected(category: Category) {
        
    }
}

extension NearbyVC: NavigationDelegate {
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentVC(_ vc: UIViewController) {
        self.presentVC(vc)
    }
}
