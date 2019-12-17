//
//  CreditationCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 14/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CreditationCell: UITableViewCell {
    
    static let identifier = "CreditationCell"
    
    enum Creditation {
        case AI
        case AINewObservation
    }
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary(customSize: 11)
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0.6
        label.textAlignment = .center
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
        
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configureCell(creditation: Creditation) {
        switch creditation {
        case .AI:
            label.text = """
Billedegenkendelses systemet er udviklet af Milan Šulc og Professor Jiri Matas fra det Tjekkiske Tekniske Universitet (CTU) i Prag, Lukáš Picek fra University of West Bohemia (UWB) i Tjekkiet og Danmarks Svampeatlas.
"""
        case .AINewObservation:
            label.text = """
            Disse navneforslag er baseret på det første billede du har tilføjet til dette fund. Billedegenkendelses systemet er udviklet af Milan Šulc og Professor Jiri Matas fra det Tjekkiske Tekniske Universitet (CTU) i Prag, Lukáš Picek fra University of West Bohemia (UWB) i Tjekkiet og Danmarks Svampeatlas.
"""
        }
    }
}
