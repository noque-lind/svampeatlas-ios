//
//  ObservationCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 30/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationCell: UITableViewCell {

    lazy var thumbImageView: UIImageView = {
       let image = UIImageView()
        image.image = #imageLiteral(resourceName: "IMG_15270")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        
        
        contentView.addSubview(thumbImageView)
        thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        thumbImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        thumbImageView.widthAnchor.constraint(equalTo: thumbImageView.heightAnchor).isActive = true
        
        contentView.addSubview(observationView)
        observationView.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 8).isActive = true
        observationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        observationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        observationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
}
