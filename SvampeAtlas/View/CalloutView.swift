//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CalloutView: UIView {

    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "IMG_15270")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
   private lazy var subtitleLabel: UILabel = {
      let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    
    private lazy var toxicityLevelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Edible")
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.alpha = 0
        return imageView
    }()
    
    
    private lazy var contentStackView: UIStackView = {
      let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.distribution = .fillEqually
        stackView.alpha = 0
        return stackView
    }()
    
    
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 10
        self.clipsToBounds = true
        self.alpha = 0
        
        self.widthAnchor.constraint(equalToConstant: 250).isActive = true
        self.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: self.topAnchor)
    }
    
    func setupConstraints(imageView: UIImageView) {
            self.imageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            self.imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalTo: imageView.widthAnchor)
            self.imageViewWidthConstraint.isActive = true
            self.imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalTo: imageView.heightAnchor)
            self.imageViewHeightConstraint.isActive = true
            self.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
            self.imageView.layer.cornerRadius = imageView.frame.width / 2
            self.layer.cornerRadius = imageView.frame.width / 2
            self.superview!.layoutIfNeeded()
    }
    
    
    
    func show(imageView: UIImageView) {
        imageViewWidthConstraint.isActive = false
        imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 80)
        imageViewWidthConstraint.isActive = true
        
        imageViewHeightConstraint.isActive = false
        imageViewTopConstraint.isActive = true
    
        self.alpha = 1
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.superview!.layoutIfNeeded()
        }) { (_) in
            self.setupContent()
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = UIColor.appSecondaryColour().withAlphaComponent(1.0)
                self.contentStackView.alpha = 1
                self.toxicityLevelImageView.alpha = 1
            }, completion: nil)
        }
    }
    
    func hide(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }) { (_) in
                self.reset()
            }
        } else {
            alpha = 0
            reset()
        }
    }
    
    func configureCalloutView(image: UIImage, title: String, subtitle: String) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    
    private func reset() {
        DispatchQueue.main.async {
            self.contentStackView.removeFromSuperview()
            self.toxicityLevelImageView.removeFromSuperview()
            self.imageViewTopConstraint.isActive = false
            self.imageViewWidthConstraint.isActive = false
            self.superview!.layoutIfNeeded()
            self.backgroundColor = UIColor.appSecondaryColour().withAlphaComponent(0.0)
            self.contentStackView.alpha = 0
            self.removeFromSuperview()
        }
    }
    
    private func setupContent() {
        self.addSubview(self.contentStackView)
        self.contentStackView.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 8).isActive = true
        self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        addSubview(toxicityLevelImageView)
        toxicityLevelImageView.leadingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: 8).isActive = true
        toxicityLevelImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        toxicityLevelImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    

}
