//
//  LocalityCollectionView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class LocalityCell: UICollectionViewCell {
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.appPrimaryHightlighed()
        view.textColor = UIColor.appWhite()
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()
    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appSecondaryColour()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
                self.setSelectionState()
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
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    func setSelectionState() {
            if self.isSelected {
                self.containerView.backgroundColor = UIColor.appGreen()
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                self.containerView.backgroundColor = UIColor.appSecondaryColour()
                self.transform = CGAffineTransform.identity
            }
    }
    
    func configureCell(locality: Locality, locked: Bool) {
        label.text = locked ? "🔒 \(locality.name)": locality.name
        setSelectionState()
    }
}
