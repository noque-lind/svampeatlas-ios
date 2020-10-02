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
       let view = ProfileImageView(defaultImage: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    private var primaryLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 0
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
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70 + (8*2)).isActive = true
        backgroundColor = UIColor.clear
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        
        contentView.addSubview(primaryLabel)
        primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        primaryLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        contentView.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        primaryLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -5).isActive = true
    }
    
    func configureCell(notification: UserNotification) {
        profileImageView.reset()
        
        let primaryText = NSMutableAttributedString(string: notification.triggerName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed()])
        primaryText.append(NSAttributedString.init(string: " "))
        
        switch notification.eventType {
        case "COMMENT_ADDED":
            profileImageView.configure(initials: notification.triggerInitials, imageURL: notification.triggerImageURL, imageSize: .full)
            
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_commentAdded_1", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            primaryText.append(NSAttributedString(string: notification.observationFullName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed().italized()]))
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_commentAdded_2", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            
        case "DETERMINATION_ADDED":
            profileImageView.configure(initials: notification.triggerInitials, imageURL: notification.triggerImageURL, imageSize: .full)
            
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_determinationAdded_1", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            primaryText.append(NSAttributedString(string: notification.observationFullName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed().italized()]))
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_determinationAdded_2", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            
        case "DETERMINATION_APPROVED":
            if notification.imageURL != nil {
                profileImageView.configure(initials: nil, imageURL: notification.imageURL, imageSize: .mini)
            } else {
                profileImageView.configure(image: #imageLiteral(resourceName: "Images_Icon"))
            }
            
            
            primaryText.deleteCharacters(in: NSRange(location: 0, length: primaryText.length))
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_determinationApproved_1", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            primaryText.append(NSAttributedString(string: notification.observationFullName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed().italized()]))
        
        case "DETERMINATION_EXPERT_APPROVED":
            profileImageView.configure(initials: nil, imageURL: notification.imageURL, imageSize: .mini)
            
            primaryText.deleteCharacters(in: NSRange(location: 0, length: primaryText.length))
            primaryText.append(NSAttributedString(string: "Fundet af: ", attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
            primaryText.append(NSAttributedString(string: notification.observationFullName, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed().italized()]))
            primaryText.append(NSAttributedString(string: NSLocalizedString("notificationCell_determinationExpertApproved", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.appPrimary()]))
        default:
            debugPrint(notification.eventType)
        }
        
        primaryLabel.attributedText = primaryText
        dateLabel.text = Date(ISO8601String: notification.date)?.convert(into: DateFormatter.Style.medium)
    }
}
