//
//  ObservationDetailHeaderCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ObservationDetailHeaderCellDelegate: class {
    func moreButtonPressed()
}

class ObservationDetailHeaderCell: UITableViewCell {
    
    private lazy var actionButton = UIButton(type: .roundedRect).then({
        $0.backgroundColor = .appSecondaryColour()
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
        $0.layer.cornerRadius = 30 / 2
        $0.setImage(#imageLiteral(resourceName: "Glyphs_Neutral"), for: [])
        $0.tintColor = .appWhite()
        $0.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
    })
    
    private lazy var idLabel = UILabel().then({
        $0.font = .appMuted()
        $0.textColor = .appWhite()
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var primaryLabel = UILabel().then({
        $0.font = .appTitle()
        $0.textColor = .appWhite()
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var secondaryLabel = UILabel().then({
        $0.font = .appPrimary()
        $0.textColor = .appWhite()
        $0.numberOfLines = 0
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var determinationView = DeterminationStatusView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    @objc private func actionButtonPressed() {
        delegate?.moreButtonPressed()
    }
    
    weak var delegate: ObservationDetailHeaderCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .appPrimaryColour()
        selectionStyle = .none
        contentView.do({
            $0.addSubview(actionButton)
            $0.addSubview(idLabel)
            $0.addSubview(primaryLabel)
            $0.addSubview(secondaryLabel)
            $0.addSubview(determinationView)
        })
        
        actionButton.do({
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
            $0.centerYAnchor.constraint(equalTo: primaryLabel.centerYAnchor).isActive = true
        })
        
        idLabel.do({
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32).isActive = true
            $0.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor).isActive = true
        })
        
        primaryLabel.do({
            $0.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 0).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: 16).isActive = true
        })
        
        secondaryLabel.do({
            $0.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor).isActive = true
        })
        
        determinationView.do({
            $0.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 16).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32).isActive = true
        })
    }
    
    func configure(observation: Observation) {
        idLabel.text = "ID: \(observation.id) | \(observation.observedBy ?? "")"
        primaryLabel.text = observation.determination.name
        determinationView.configure(validationStatus: observation.validationStatus)
    }
}
