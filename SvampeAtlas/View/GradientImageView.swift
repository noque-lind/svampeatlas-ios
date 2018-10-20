//
//  GradientImageView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class GradientImageView: UIView {

        private var imageView: UIImageView!
        private var gradient: CAGradientLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = imageView.bounds
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        setupImageView()
    }
    
    private func setupImageView() {
            imageView = UIImageView()
            imageView.alpha = 0.5
            imageView.backgroundColor = UIColor.clear
            imageView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(imageView, at: 0)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            
            gradient = CAGradientLayer()
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.locations = [0.0, 1.0]
            gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.frame = self.bounds
            self.layer.mask = gradient
        }
        

        func setImage(image: UIImage, fade: Bool) {
            if fade {
                UIView.transition(with: self.imageView,
                                  duration:3.0,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = image },
                                  completion: nil)
            } else {
                imageView.image = image
            }
            
        }
        
    }
