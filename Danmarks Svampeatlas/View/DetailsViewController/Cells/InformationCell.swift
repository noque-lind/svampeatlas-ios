//
//  InformationCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class InformationCell: UITableViewCell {
    
    private lazy var informationView = InformationView(style: .light).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        informationView.reset()
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.do({
            $0.addSubview(informationView)
        })
        
        informationView.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        })
    }
    
    func configure(information: [(String, String)]) {
        informationView.addInformation(information: information)
    }
}
