//
//  SearchCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 22/05/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    private var containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.backgroundColor = UIColor.appSecondaryColour()
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        let searchIcon: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 14).isActive = true
            view.widthAnchor.constraint(equalToConstant: 14).isActive = true
            view.image = #imageLiteral(resourceName: "Search")
            return view
        }()
        
        view.addSubview(searchIcon)
        searchIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()

    override func layoutSubviews() {
        containerView.layer.cornerRadius = containerView.frame.height / 2
        super.layoutSubviews()
    }
    
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
        
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.heightAnchor.constraint(equalToConstant: 25).isActive = true
            label.text = "Søg på en vært her 👇"
            return label
        }()
        
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        
        
        contentView.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        containerView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
}
