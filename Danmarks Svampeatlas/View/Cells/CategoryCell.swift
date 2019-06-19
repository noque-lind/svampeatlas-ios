//
//  CategoryCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimary()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = UIColor.appThird()
            } else {
                label.textColor = UIColor.appWhite()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configureCell(title: String) {
        label.text = title
    }
}
