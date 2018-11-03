//
//  NotificationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    private var profileImageView: ProfileImageView = {
       let view = ProfileImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    private var primaryLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var dateLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimary(customSize: 9)
        label.textColor = UIColor.appWhite()
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
        
        contentView.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        contentView.addSubview(primaryLabel)
        primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        primaryLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5).isActive = true
        primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        
        contentView.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        primaryLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -5).isActive = true
    }
    
    func configureCell(notification: UserNotification) {
        let primaryText = NSMutableAttributedString(string: notification.triggerName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed()])
        
        switch notification.eventType {
        case "COMMENT_ADDED":
            primaryText.append(NSAttributedString(string: " har kommenteret på dit fund af: ", attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
        case "DETERMINATION_ADDED":
            primaryText.append(NSAttributedString(string: " har tilføjet en bestemmelse til dit fund af: ", attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
        case "DETERMINATION_APPROVED":
            primaryText.append(NSAttributedString(string: " har godkendt dit fund af : ", attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
        default:
            print(notification.eventType)
        }
        
        primaryText.append(NSAttributedString(string: notification.observationFullName, attributes: [NSAttributedString.Key.font: UIFont(name: "AvenirNext-UltraLightItalic", size: 12)]))
        
        primaryLabel.attributedText = primaryText
        
        dateLabel.text = Date(ISO8601String: notification.date)?.convert(into: DateFormatter.Style.medium)
        
        guard let imageURL = notification.imageURL else {return}
        profileImageView.configure(initials: "", imageURL: imageURL)
        }
    
}
