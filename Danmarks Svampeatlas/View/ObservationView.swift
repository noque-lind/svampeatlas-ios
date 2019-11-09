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
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var validationView: ValidationView = {
       let view = ValidationView()
        view.widthAnchor.constraint(equalToConstant: 25).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fill
        stackView.spacing = 20
        
        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subtitleLabel)
            return stackView
        }()
        
        let userNameStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.spacing = 6
            stackView.axis = .horizontal
            stackView.distribution = .fill
        
            let profileImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.image = #imageLiteral(resourceName: "Glyphs_Profile")
                imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
                imageView.contentMode = UIImageView.ContentMode.center
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
        imageView.image = #imageLiteral(resourceName: "Glyphs_DisclosureButton")
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
        
        addSubview(validationView)
        validationView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        validationView.centerXAnchor.constraint(equalTo: disclosureIndicator.centerXAnchor).isActive = true
        
        self.addSubview(self.contentStackView)
        self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.contentStackView.trailingAnchor.constraint(equalTo: disclosureIndicator.leadingAnchor, constant: -8).isActive = true
        self.contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        
    }
    
    func configure(observation: Observation) {
        titleLabel.text = observation.speciesProperties.name
        titleLabel.sizeToFit()
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
        
        subtitleLabel.sizeToFit()
        userNameLabel.text = observation.observedBy
        validationView.configure(validationStatus: observation.validationStatus)
    }
    
    func setPadding(padding: UIEdgeInsets) {
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 0.0, bottom: 16, right: 0.0)
    }
}
