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
        let view = ProfileImageView(defaultImage: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
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

        
        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.distribution = .fill
            stackView.addArrangedSubview(profileImageView)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(dateLabel)
            return stackView
        }()
        
//        contentView.addSubview(profileImageView)
//        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
//
        contentView.addSubview(upperStackView)
        upperStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        upperStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        upperStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        contentView.addSubview(contentLabel)
        contentLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        contentLabel.topAnchor.constraint(equalTo: upperStackView.bottomAnchor, constant: 4).isActive = true
    }
    
    func configureCell(comment: Comment) {
        nameLabel.text = comment.commenterName
        contentLabel.text = comment.content
        dateLabel.text = Date(ISO8601String: comment.date)?.convert(into: DateFormatter.Style.full)
        profileImageView.configure(initials: comment.initials, imageURL: comment.commenterProfileImageURL, imageSize: .full)
    }
}
