//
//  CautionCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 21/01/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//


import UIKit

class CautionCell: UITableViewCell {
    
    static let identifier = "CautionCell"
    
    enum ´Type {
        case lowConfidence
    }
    
    private let iconImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "Icons_MenuIcons_About").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .appRed()
imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary(customSize: 11)
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0.6
        label.numberOfLines = 0
        return label
    }()
    
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
        
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configureCell(type: ´Type) {
        switch type {
        case .lowConfidence:
            label.text = NSLocalizedString("cautionCell_lowConfidence", comment: "")
        }
}
}

