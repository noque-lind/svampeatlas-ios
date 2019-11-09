//
//  ValidationView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ValidationView: UIView {
    
    private let imageView: UIImageView = {
       let view = UIImageView()
        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.height / 2
        super.layoutSubviews()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func configure(validationStatus: Observation.ValidationStatus) {
        switch validationStatus {
        case .approved:
           backgroundColor = UIColor.appGreen()
            imageView.image = #imageLiteral(resourceName: "Glyphs_Checkmark")
        case .rejected:
            backgroundColor = UIColor.appRed()
            imageView.image = #imageLiteral(resourceName: "Glyphs_Denied")
        case .unknown, .verifying:
            backgroundColor = UIColor.appPrimaryColour()
            imageView.image = #imageLiteral(resourceName: "Glyphs_Neutral")
        }
    }
}
