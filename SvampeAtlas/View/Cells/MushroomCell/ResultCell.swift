//
//  ResultCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var mushroomThumbImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    func configureCell(name: String) {
        nameLabel.text = name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        nameLabel.font = UIFont.appPrimaryHightlighed()
        nameLabel.textColor = UIColor.appWhite()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
