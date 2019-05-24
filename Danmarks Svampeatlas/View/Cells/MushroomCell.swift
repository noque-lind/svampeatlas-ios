//
//  MushroomCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomCell: UITableViewCell {
    
    static var estimatedRowHeight = 150
    
    private lazy var mushroomView: MushroomView = {
       let view = MushroomView(fullyRounded: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        contentView.addSubview(mushroomView)
        mushroomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        mushroomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        mushroomView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        mushroomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    func configureCell(mushroom: Mushroom) {
        mushroomView.configure(mushroom: mushroom)
    }
}
