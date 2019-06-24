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
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 0
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subtitleLabel)
            return stackView
        }()
        
        let userNameStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.spacing = 4
            stackView.axis = .horizontal
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.heightAnchor.constraint(equalToConstant: 14).isActive = true
            
            let profileImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                imageView.image = #imageLiteral(resourceName: "Profile")
                return imageView
            }()
            stackView.addArrangedSubview(profileImageView)
            stackView.addArrangedSubview(userNameLabel)
            return stackView
        }()
        
        stackView.addArrangedSubview(upperStackView)
        stackView.addArrangedSubview(userNameStackView)
        stackView.alpha = 1
        return stackView
    }()
    
    private lazy var disclosureIndicator: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "DisclosureButton")
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        addSubview(disclosureIndicator)
        disclosureIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        disclosureIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        
        self.addSubview(self.contentStackView)
        self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.contentStackView.trailingAnchor.constraint(equalTo: disclosureIndicator.leadingAnchor, constant: -4).isActive = true
        self.contentStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
    }
    
    func configure(observation: Observation) {
        titleLabel.text = observation.speciesProperties.name
        subtitleLabel.text = nil
        if let dateString = Date(ISO8601String: observation.date!)?.convert(into: .short, ignoreRecentFormatting: false, ignoreTime: true) {
            subtitleLabel.text = dateString
        }
        
        if let locationString = observation.location {
            if subtitleLabel.text == nil {
                subtitleLabel.text = locationString
            } else {
                subtitleLabel.text?.append(", \(locationString)")
            }
        }
        userNameLabel.text = observation.observedBy
    }
}
