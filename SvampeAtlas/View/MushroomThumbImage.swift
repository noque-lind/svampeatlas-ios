//
//  MushroomThumbImage.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomThumbImage: UIImageView {

    var circleLayer: CAShapeLayer?
    
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        round()
    }
    
    
//    func configureLayers() {
//        if circleLayer == nil {
//            let circleCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height)
//            let circleRadius = bounds.size.width / 2
//            let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: CGFloat(0), endAngle: CGFloat.pi * 2, clockwise: true)
//            let oval = UIBezierPath(ovalIn: frame)
//            circleLayer = CAShapeLayer()
//            circleLayer?.path = oval.cgPath
//            layer.mask = circleLayer
//        }
//    }
    
    func setupView() {
        self.clipsToBounds = true
        self.layer.shadowOpacity = 0.7
//        round()
    }
    
    
//    private func round() {
//        var path: UIBezierPath!
//        if UIApplication.shared.statusBarOrientation.isPortrait {
//            path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
//        } else {
//        path = UIBezierPath(roundedRect: self.frame, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
//        }
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = path.cgPath
//        layer.mask = shapeLayer
//    }
    
    private func round() {
        let radius = self.frame.size.height / 2
        print(radius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = shapeLayer
    }
}
