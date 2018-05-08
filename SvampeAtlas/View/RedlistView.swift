//
//  RedlistView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class RedlistView: UIView {

    private var label: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    private func setupView() {
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    }
    
    func configure(_ redlistStatus: String) {
        label.text = redlistStatus
        
        switch redlistStatus {
        case "LC", "NT":
            backgroundColor = UIColor.appGreen()
        case "CR", "EN":
            backgroundColor = UIColor.appRed()
        case "VU":
            backgroundColor = UIColor.appYellow()
        default:
            backgroundColor = UIColor.appWhite()
        }
    }
}
