//
//  CategoryCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = UIColor.appThirdColour()
            } else {
                label.textColor = UIColor.appSecondaryColour()
            }
        }
    }
    
    override func awakeFromNib() {
        label.textColor = UIColor.appSecondaryColour()
        label.font = UIFont.appHeaderDetails()
    }
    
    
    

    func configureCell(title: String) {
        label.text = title
    }
}
