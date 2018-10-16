//
//  ObservationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 30/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationCell: UITableViewCell {

   private lazy var button: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var thumbImageView: RoundedImageView = {
       let imageView = RoundedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        return imageView
    }()
    
    private lazy var observationView: ObservationView = {
       let view = ObservationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none

        contentView.addSubview(button)
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let stackView: UIStackView = {
           let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.addArrangedSubview(thumbImageView)
            view.addArrangedSubview(observationView)
            view.spacing = 8
            return view
        }()
        
        contentView.addSubview(stackView)
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        stackViewLeadingConstraint.isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
    }
    
    func configure(observation: Observation) {
        observationView.configure(observation: observation)
        
        if let imageURL = observation.images?.first?.url {
                thumbImageView.configureImage(url: imageURL)
                thumbImageView.isHidden = false
                stackViewLeadingConstraint.isActive = false
                stackViewLeadingConstraint.constant = 0
                stackViewLeadingConstraint.isActive = true
        } else {
                thumbImageView.isHidden = true
//                thumbImageView.image = nil
                stackViewLeadingConstraint.isActive = false
                stackViewLeadingConstraint.constant = 8
                stackViewLeadingConstraint.isActive = true
        }
    }
}
