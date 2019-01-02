//
//  MushroomThumbImage.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class RoundedImageView: UIView {

    private lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.mask = shapeLayer
        return imageView
    }()
    
    private let shapeLayer = CAShapeLayer()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        round()
    }
    
    private func setupView() {
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowPath = shapeLayer.path
        clipsToBounds = false
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    private func round() {
        let radius = frame.height / 2 - 7
        shapeLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        }
        

    func configureImage(url: String?) {
            imageView.image = nil
        guard let url = url else {return}
        DataService.instance.getImage(forUrl: url, size: .mini) { [weak self] (image, imageURL) in
                        self?.imageView.image = image
                }
            }
}
