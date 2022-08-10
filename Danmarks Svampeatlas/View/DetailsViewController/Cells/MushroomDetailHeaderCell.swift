//
//  MushroomDetailHeaderTableViewCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomDetailsHeaderCell: UITableViewCell {
    
    private lazy var primaryLabel = UILabel().then({
        $0.font = .appTitle()
        $0.textColor = .appWhite()
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var secondaryLabel = UILabel().then({
        $0.font = .appPrimaryHightlighed()
        $0.textColor = .appWhite()
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var redlistView = RedlistView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var favoriteButton = UIButton().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
        $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
        $0.setImage(#imageLiteral(resourceName: "Icons_Utils_Favorite_Make").withRenderingMode(.alwaysTemplate), for: [])
        $0.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
    })
    
    private var mushroom: Mushroom?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .appPrimaryColour()
        selectionStyle = .none
        
        contentView.do({
            $0.addSubview(primaryLabel)
            $0.addSubview(secondaryLabel)
            $0.addSubview(redlistView)
            $0.addSubview(favoriteButton)
        })
        
        primaryLabel.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        })
        
        favoriteButton.do({
            $0.centerYAnchor.constraint(equalTo: primaryLabel.centerYAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            $0.leadingAnchor.constraint(equalTo: primaryLabel.trailingAnchor, constant: 32).isActive = true
        })
        
        secondaryLabel.do({
            $0.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 0).isActive = true
            $0.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: secondaryLabel.trailingAnchor).isActive = true
        })
        
        redlistView.do({
            $0.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 16).isActive = true
            $0.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32).isActive = true
        })
    }
    
    @objc private func favoriteButtonPressed() {
        if favoriteButton.tintColor == UIColor.appWhite() {
            guard let mushroom = mushroom else {return}
            Database.instance.mushroomsRepository.saveFavorite(mushroom) { [weak self] result in
                switch result {
                case .success:
                    UIView.animate(withDuration: 0.2) {
                        self?.favoriteButton.tintColor = .appGreen()
                        self?.favoriteButton.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                    } completion: { (_) in
                        UIView.animate(withDuration: 0.1) {
                            self?.favoriteButton.transform = .identity
                        }
                    }
                case .failure: return
                }

            }
        } else {
            guard let mushroom = mushroom else {return}
            Database.instance.mushroomsRepository.removeAsFavorite(mushroom) { [weak self] result in
                switch result {
                case .success:
                    UIView.animate(withDuration: 0.2) {
                        self?.favoriteButton.tintColor = .appWhite()
                        self?.favoriteButton.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                    } completion: { (_) in
                        UIView.animate(withDuration: 0.1) {
                            self?.favoriteButton.transform = .identity
                        }
                    }
                case .failure(let error): break
                }
            }
           
        }
    }
    
    func configure(mushroom: Mushroom) {
        self.mushroom = mushroom
        if let localizedName = mushroom.localizedName {
            primaryLabel.attributedText = .init(string: localizedName, attributes: [.font: UIFont.appTitle()])
            secondaryLabel.attributedText = mushroom.fullName.italized(font: .appPrimary())
        } else {
            primaryLabel.attributedText = mushroom.fullName.italized(font: .appTitle())
    }
        if let redlistStatus = mushroom.redlistStatus {
            redlistView.configure(redlistStatus: redlistStatus)
        }
        
        if Database.instance.mushroomsRepository.exists(mushroom: mushroom) {
            favoriteButton.tintColor = .appGreen()
        } else {
            favoriteButton.tintColor = .appWhite()
        }
    }
}
