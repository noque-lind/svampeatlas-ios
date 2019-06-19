//
//  MapVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 07/06/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MapVC: UIViewController {

    var mapView: NewMapView = {
       let view = NewMapView(type: .observations(detailed: false))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
         self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
        super.viewWillAppear(animated)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
        
        view.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.title = "Fundets lokation"
    }
}
