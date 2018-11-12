//
//  NotificationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    private var profileImageView: ProfileImageView = {
        let view = ProfileImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.appPrimaryHightlighed()
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary(customSize: 9)
        label.textAlignment = .right
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.addArrangedSubview(profileImageView)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(dateLabel)
            return stackView
        }()
        
        contentView.addSubview(upperStackView)
        upperStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        upperStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        upperStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        contentView.addSubview(contentLabel)
        contentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: upperStackView.bottomAnchor, constant: 4).isActive = true
    }
    
    func configureCell(comment: Comment) {
        nameLabel.text = "Thorbjørn"
        contentLabel.text = comment.content
        dateLabel.text = Date(ISO8601String: comment.date)?.convert(into: DateFormatter.Style.full)
        
        
        //        guard let imageURL = notification.imageURL else {return}
        //        profileImageView.configure(initials: "", imageURL: imageURL)
        //        }
        
    }
}
