//
//  MushroomContainerView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomContainerView: UIView {

    override func awakeFromNib() {
        setupView()
    }

    
    func setupView() {
        layer.shadowOpacity = 0.8
        layer.cornerRadius = 10
        backgroundColor = UIColor.appWhite()
    }
}
