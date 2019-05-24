//
//  CustomNavigationControllerViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
    
    private var appNavigationBar: AppNavigationBar = {
       let view = AppNavigationBar(navigationBarType: .solid)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setLeftItem(itemType: .menuButton)
        return view
    }()
    

    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    

    private func setupView() {
//
        
        view.addSubview(appNavigationBar)
        appNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        appNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        appNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        appNavigationBar.bottomAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        
        self.setNavigationBarHidden(true, animated: false)
        
        
//        let navigationBar = UINavigationBar()
//        self.
//        navigationBar.backgroundColor = UIColor.red
//        
//        view.backgroundColor = UIColor.appPrimaryColour()
//        navigationBar.tintColor = UIColor.appWhite()
//        navigationBar.barTintColor = UIColor.appPrimaryColour()
//        navigationBar.isTranslucent = false
//        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appHeader()]
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.setLeftBarButton(menuButton, animated: false)
//        navigationBar.shadowImage = UIImage()
    }

}
