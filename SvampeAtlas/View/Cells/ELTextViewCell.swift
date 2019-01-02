//
//  ELTextViewCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 22/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {
    
    private var textView: ELTextView = {
       let view = ELTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appSecondaryColour()
        view.textColor = UIColor.appWhite()
        view.font = UIFont.appPrimaryHightlighed()
        view.descriptionTextColor = UIColor.appWhite()
        view.placeholder = "Svampen havde store porer ..."
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
    private func setupView() {
        separatorInset = UIEdgeInsets(top: 0.0, left: 10000, bottom: 0.0, right: 0.0)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
    }
    
    func configureCell(descriptionText: String, placeholder: String, content: String?, delegate: ELTextViewDelegate?) {
        textView.descriptionText = descriptionText
        textView.placeholder = placeholder
        textView.text = content
        textView.delegate = delegate
    }
    
    
    
}
