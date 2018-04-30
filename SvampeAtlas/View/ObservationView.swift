//
//  ObservationView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 30/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
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
        
        self.addSubview(self.contentStackView)
        self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        addSubview(toxicityLevelImageView)
        toxicityLevelImageView.leadingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: 8).isActive = true
        toxicityLevelImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        toxicityLevelImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
}

}
