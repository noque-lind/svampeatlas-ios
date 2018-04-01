//
//  MushroomThumbImage.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomThumbImage: UIImageView {

    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        round()
        super.layoutSubviews()
    }
    

    func setupView() {
        self.clipsToBounds = true
    }
    
    
    private func round() {
        let radius = (self.frame.width / 2) - 5
        print(radius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = shapeLayer
    }
}
