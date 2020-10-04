//
//  SectionHeaderView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class SectionHeaderView: UITableViewHeaderFooterView, ELSectionHeaderCell {
    
    static let identifier = "SectionHeaderView"
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = UIFont.appDivider()
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    
    convenience init() {
        self.init(reuseIdentifier: SectionHeaderView.identifier)
    setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundView = UIImageView()
        
        let contentView: UIView = {
           let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.appPrimaryColour()
            view.layer.cornerRadius = CGFloat.cornerRadius()
            view.layer.maskedCorners = [CACornerMask.layerMaxXMaxYCorner, CACornerMask.layerMaxXMinYCorner]
//            view.layer.shadowOpacity = Float.shadowOpacity()
//            view.layer.shadowOffset = CGSize.shadowOffset()
            
            view.addSubview(label)
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true
            return view
        }()
        
        let stackView: UIStackView = {
           let view = UIStackView()
            view.alignment = .leading
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addArrangedSubview(contentView)
            return view
        }()
        
        
    addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func configure(title text: String) {
        label.text = text
    }
}
