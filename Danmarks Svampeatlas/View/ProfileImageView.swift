//
//  ProfileImageView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {
    
    private var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "f1a9d2f0.LogoSmallest")
        imageView.setContentCompressionResistancePriority(UILayoutPriority(249), for: NSLayoutConstraint.Axis.vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(249), for: NSLayoutConstraint.Axis.horizontal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var imageURL: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        imageView.layer.cornerRadius = frame.height / 2
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    
    private func setupView() {
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 2.0
        
        backgroundColor = UIColor.clear
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    func configure(initials: String, imageURL: String?) {
        self.imageURL = imageURL
        imageView.image = nil
        label.text = initials.uppercased()
        imageView.alpha = 0.7
        backgroundColor = UIColor.appPrimaryColour()
        
        guard let imageURL = imageURL else {return}
        DataService.instance.getImage(forUrl: imageURL) { (image, imageURL) in
            DispatchQueue.main.async {
                if self.imageURL == imageURL {
                    self.imageView.image = image
                }
            }
        }
    }
    
    func reset() {
        label.text = ""
        imageView.image = #imageLiteral(resourceName: "f1a9d2f0.LogoSmallest")
        imageView.alpha = 1
        backgroundColor = UIColor.clear
    }
}
