//
//  DeterminationStatusView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class DeterminationStatusView: UIView {
    
    private var iconImageView = UIImageView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
    })
    
    private lazy var iconView = UIView().then({ (view) in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconImageView)
        view.layer.cornerRadius = .cornerRadius()
        iconImageView.do({
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        })
    })
    
    private var label = UILabel().then({
        $0.font = .appPrimary(customSize: 12)
        $0.textColor = .appWhite()
    })
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        let stackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.spacing = 8
            $0.addArrangedSubview(iconView)
            $0.addArrangedSubview(label)
        })
        
        addSubview(stackView)
        ELSnap.snapView(stackView, toSuperview: self)
    }
    
    func configure(validationStatus: Observation.ValidationStatus) {
        switch validationStatus {
        case .approved:
            iconView.backgroundColor = UIColor.appGreen()
            iconImageView.image = #imageLiteral(resourceName: "Glyphs_Checkmark")
            label.text = "Bestemmmelsen er godkendt"
        case .rejected:
            iconView.backgroundColor = UIColor.appRed()
            iconImageView.image = #imageLiteral(resourceName: "Glyphs_Denied")
            label.text = "Bestemmelsen er afvist"
        case .unknown, .verifying:
            iconView.backgroundColor = UIColor.appPrimaryColour()
            iconImageView.image = #imageLiteral(resourceName: "Glyphs_Neutral")
            label.text = "Bestemmmelsen valideres"
        }
    }
}
