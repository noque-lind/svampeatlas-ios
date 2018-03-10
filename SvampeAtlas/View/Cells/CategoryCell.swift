//
//  CategoryCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = UIColor.appThirdColour()
            } else {
                label.textColor = UIColor.appSecondaryColour()
            }
        }
    }
    
    @IBOutlet weak var label: UILabel!
    

    func configureCell(title: String) {
        label.text = title
    }
}
