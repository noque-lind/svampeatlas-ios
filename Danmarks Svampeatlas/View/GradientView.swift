//
//  GradientView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
class GradientView: UIView {
    
    var gradient = CAGradientLayer()

    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        gradient.frame = bounds
        super.layoutSubviews()
    }
        
    func setupView() {
        gradient.frame = frame
        gradient.colors = [UIColor.appSecondaryColour().cgColor, UIColor.appPrimaryColour().cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.locations = [0.0, 1.0]
        layer.addSublayer(gradient)
    }
}
