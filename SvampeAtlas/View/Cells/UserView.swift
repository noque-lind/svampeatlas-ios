//
//  UserCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class UserView: UIView {

    private var profileImageView: ProfileImageView = {
       let view = ProfileImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    private var primaryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        label.isHidden = true
        return label
    }()
    
    private var secondaryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        let contentStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.distribution = .fill
            stackView.spacing = 16
            
            let profileImageViewContainerView: UIView = {
               let view = UIView()
                view.backgroundColor = UIColor.clear
                view.addSubview(profileImageView)
                profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                profileImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                profileImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                return view
            }()
            
            let lowerStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                stackView.addArrangedSubview(primaryLabel)
                stackView.addArrangedSubview(secondaryLabel)
                return stackView
            }()
            stackView.addArrangedSubview(profileImageViewContainerView)
            stackView.addArrangedSubview(lowerStackView)
            return stackView
        }()
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor
            , constant: 0).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(user: User) {
        profileImageView.configure(initials: user.initials, imageURL: user.imageURL)
        primaryLabel.text = user.name
        secondaryLabel.text = "215 godkendte fund"
        profileImageView.isHidden = false
        primaryLabel.isHidden = false
        secondaryLabel.isHidden = false
    }
    
    func configureAsGuest() {
        primaryLabel.text = "Svampe atlas"
        secondaryLabel.text = "Log ind for at dele dine svampefund med andre, og få ekspertvalidering af Danmarks førende svampeeksperter"
        primaryLabel.isHidden = false
        secondaryLabel.isHidden = false
    }
}
