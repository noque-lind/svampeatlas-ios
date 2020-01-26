//
//  SearchCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 22/05/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    private lazy var containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.backgroundColor = UIColor.appSecondaryColour()
        view.layer.cornerRadius = 20
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pressed))
        view.addGestureRecognizer(tapGesture)
    
        let searchIcon: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 14).isActive = true
            view.widthAnchor.constraint(equalToConstant: 14).isActive = true
            view.image = #imageLiteral(resourceName: "Glyphs_Search")
            return view
        }()
        
        view.addSubview(searchIcon)
        searchIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()

    var searchButtonPressed: (() -> ())?
    

    @objc private func pressed() {
        searchButtonPressed?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func setupView() {
        backgroundColor = UIColor.white
        selectionStyle = .none
        
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appPrimaryColour()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = NSLocalizedString("searchCell_title", comment: "")
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
