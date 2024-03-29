//
//  SettingsInformationCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 21/09/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import Then
import UIKit

class SettingsInformationCell: UITableViewCell {
    static let identifier = "SettingsInformationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        let view: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.appPrimaryColour()
            view.layer.cornerRadius = CGFloat.cornerRadius()
            
            let titleLabel = UILabel().then({
                $0.font = UIFont.appPrimary()
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.textAlignment = .center
                $0.numberOfLines = 0
                $0.textColor = .appWhite()
                $0.text = NSLocalizedString("settingsInformationCell_message", comment: "")
            })
            
            view.addSubview(titleLabel)
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
            return view
        }()
        
        contentView.addSubview(view)
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
}
