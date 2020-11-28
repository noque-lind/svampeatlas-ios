//
//  TextCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
    
    private let label = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.appPrimary()
        $0.textColor = UIColor.appWhite()
        $0.numberOfLines = 0
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.do({
            $0.addSubview(label)
        })
        
        label.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        })
    }
    
    func configure(text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        paragraphStyle.hyphenationFactor = 1.0
        
        // Swift 4.2++
        let attributedString = NSMutableAttributedString(string: text.capitalizeFirst(), attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        label.attributedText = attributedString
    }
    
}
