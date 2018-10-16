//
//  UserCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    private var profileImageView: UIImageView = {
       let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        view.layer.shadowOpacity = 0.4
        return view
    }()
    
    private var nameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    private var secondaryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
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
        
        contentView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        

        let contentStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(secondaryLabel)
            return stackView
        }()
        
        contentView.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    
    }

    func configureCell(user: User) {
        nameLabel.text = user.name
    }
}
