//
//  NavigationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NavigationCell: UITableViewCell {

    private lazy var gradientView: CAGradientLayer = {
      let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = [UIColor.appPrimaryColour().cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    private var iconImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    private var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed(customSize: 16)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            layer.insertSublayer(gradientView, at: 0)
            gradientView.frame = self.bounds
        } else {
            gradientView.removeFromSuperlayer()
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
    }

    func configureCell(navigationItem: NavigationItem) {
        iconImageView.image = navigationItem.icon
        label.text = navigationItem.title
    }
}
