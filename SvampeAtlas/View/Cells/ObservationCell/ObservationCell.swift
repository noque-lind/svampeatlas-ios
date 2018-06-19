//
//  ObservationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 30/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationCell: UITableViewCell {

    lazy var button: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var redlistView: RedlistView = {
        let view = RedlistView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        return view
    }()
    
    lazy var thumbImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "IMG_15270")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(redlistView)
        redlistView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 4).isActive = true
        redlistView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4).isActive = true
        return imageView
    }()
    
    
    lazy var observationView: ObservationView = {
       let view = ObservationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        
        
        contentView.addSubview(thumbImageView)
        thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        thumbImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        thumbImageView.widthAnchor.constraint(equalTo: thumbImageView.heightAnchor).isActive = true
        
        contentView.addSubview(observationView)
        observationView.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 8).isActive = true
        observationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        observationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        observationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configure(observation: Observation) {
        observationView.configure(observation: observation)
        redlistView.configure(observation.determinationView?.redlistStatus)        
    }
}
