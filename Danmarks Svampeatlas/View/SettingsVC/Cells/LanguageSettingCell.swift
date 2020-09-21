//
//  LanguageSettingCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 21/09/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import Then

class LanguageSettingCell: UITableViewCell {
    static let identifier = "LanguageSettingCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let iconView = UIImageView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.red
            $0.widthAnchor.constraint(equalToConstant: 16).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 16).isActive = true
            $0.image = #imageLiteral(resourceName: "Images_Icon")
            contentView.addSubview($0)
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        })
        
        _ = UILabel().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "Indstil sprog"
            $0.font = UIFont.appPrimary()
            contentView.addSubview($0)
            $0.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8).isActive = true
            $0.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        })
    }
    
    
}
