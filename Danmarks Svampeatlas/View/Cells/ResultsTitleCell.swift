//
//  ResultsTitleCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 22/10/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ResultsTitleCell: UITableViewCell {
    
    static let identifier = "ResultsTitleCell"
    
    private lazy var headerLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appTitle()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var secondaryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var topView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
       
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, subtitle: String) {
        headerLabel.text = title
        secondaryLabel.text = subtitle
    }
 
    private func setupView() {
        backgroundColor = .clear
        let stackView: UIStackView = {
            let view = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addArrangedSubview(headerLabel)
            view.addArrangedSubview(secondaryLabel)
            view.distribution = .fillProportionally
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    
}
