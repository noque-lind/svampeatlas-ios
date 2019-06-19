//
//  SettingCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    private var iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textAlignment = .right
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        contentLabel.textColor = selected ? UIColor.appThird(): UIColor.appWhite()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        let stackView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.addArrangedSubview(descriptionLabel)
            view.addArrangedSubview(contentLabel)
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configureCell(icon: UIImage, description: String, content: String) {
        iconImageView.image = icon
        descriptionLabel.text = description
        contentLabel.text = content
    }
}

