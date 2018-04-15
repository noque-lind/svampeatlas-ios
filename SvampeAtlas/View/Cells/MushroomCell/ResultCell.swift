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
    @IBOutlet weak var confidenceLabel: UILabel!
    
    
    func configureCell(name: String, confidence: CGFloat) {
        nameLabel.text = name
        confidenceLabel.text = "\(Int(confidence * 100))% sikker"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        nameLabel.font = UIFont.appHeaderDetails()
        nameLabel.textColor = UIColor.appWhite()
        confidenceLabel.font = UIFont.appPrimaryHightlighed()
        confidenceLabel.textColor = UIColor.appWhite()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
