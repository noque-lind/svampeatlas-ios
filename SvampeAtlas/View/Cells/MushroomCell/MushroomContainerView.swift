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

    override func layoutSubviews() {
        round()
        super.layoutSubviews()
    }
    
    private func setupView() {
        backgroundColor = UIColor.white
    }
    
    
    private func round() {
        let radius = 5.0
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = shapeLayer
    }
}
