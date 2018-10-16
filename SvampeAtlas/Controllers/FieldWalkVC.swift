//
//  FieldWalkVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 16/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class FieldWalkVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Denne funktion kommer snart"
            label.textColor = UIColor.appWhite()
            label.textAlignment = .center
            return label
        }()
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Do any additional setup after loading the view.
    }
}
