//
//  ObservationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 30/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NewObservationCell: UITableViewCell {
    
    private lazy var roundedImageView = RoundedImageView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
    })
    
    private lazy var titleLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .appPrimaryHightlighed()
        $0.numberOfLines = 0
        $0.textColor = .appWhite()
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private lazy var subtitleLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .appPrimary()
        $0.textColor = .appWhite()
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private lazy var userNameLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.appPrimary()
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.textColor = UIColor.appWhite()
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        backgroundColor = .clear
        
        let stackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.spacing = 8
            $0.axis = .horizontal
            $0.addArrangedSubview(roundedImageView)
            $0.addArrangedSubview(UIView().then({
                $0.backgroundColor = .clear
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.addSubview(titleLabel)
                $0.addSubview(subtitleLabel)
                $0.addSubview(userNameLabel)
                
                titleLabel.topAnchor.constraint(equalTo: $0.topAnchor, constant: 16).isActive = true
                titleLabel.leadingAnchor.constraint(equalTo: $0.leadingAnchor).isActive = true
                titleLabel.trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
                userNameLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8).isActive = true
                userNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
                userNameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
                userNameLabel.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -16).isActive = true
            }))
        })
        
        
        contentView.do({
            $0.addSubview(stackView)
        })
        
        stackView.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        })
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
        
        if let imageURL = observation.images?.first?.url {
                roundedImageView.configureImage(url: imageURL)
                roundedImageView.isHidden = false
        } else {
                roundedImageView.isHidden = true
        }
    }
    
}

class ObservationCell: UITableViewCell {
    
    private lazy var roundedImageView: RoundedImageView = {
       let imageView = RoundedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return imageView
    }()
    
    private lazy var observationView: ObservationView = {
       let view = ObservationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setPadding(padding: UIEdgeInsets(top: 16, left: 0.0, bottom: 16, right: 0.0))
        return view
    }()
    
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        let stackView: UIStackView = {
           let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.addArrangedSubview(roundedImageView)
            view.addArrangedSubview(observationView)
            view.spacing = 16
            return view
        }()
        
        contentView.addSubview(stackView)
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        stackViewLeadingConstraint.isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
    }
    
    func configure(observation: Observation) {
        observationView.configure(observation: observation)
        
        if let imageURL = observation.images?.first?.url {
                roundedImageView.configureImage(url: imageURL)
                roundedImageView.isHidden = false
                stackViewLeadingConstraint.isActive = false
                stackViewLeadingConstraint.constant = 0
                stackViewLeadingConstraint.isActive = true
        } else {
                roundedImageView.isHidden = true
//                thumbImageView.image = nil
                stackViewLeadingConstraint.isActive = false
                stackViewLeadingConstraint.constant = 8
                stackViewLeadingConstraint.isActive = true
        }
    }
}
