//
//  MapVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 07/06/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MapVC: UIViewController {

    private lazy var categoryView: CategoryView<NewMapView.Categories> = {
        let items = NewMapView.Categories.allCases.compactMap({Category<NewMapView.Categories>(type: $0, title: $0.description)})
        let view = CategoryView<NewMapView.Categories>.init(categories: items, firstIndex: 0)
        
        view.categorySelected = { [unowned mapView] category in
             mapView.filterByCategory(category: category)
        }
    
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        title = NSLocalizedString("mapVC_title", comment: "")
        view.backgroundColor = UIColor.appPrimaryColour()
        
        view.addSubview(categoryView)
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        categoryView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view.addSubview(mapView)
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
