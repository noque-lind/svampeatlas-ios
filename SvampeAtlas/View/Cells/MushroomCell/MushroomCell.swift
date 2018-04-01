//
//  MushroomCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomCell: UITableViewCell {
    
    @IBOutlet weak var thumbImage: MushroomThumbImage!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var secondaryTitle: UILabel!
    
    @IBOutlet weak var dkAmountTitle: UILabel!
    @IBOutlet weak var dkAmount: UILabel!
    @IBOutlet weak var dkLatestTitle: UILabel!
    @IBOutlet weak var dkLatest: UILabel!
    
    @IBOutlet weak var toxicityLevelStackView: UIStackView!
    @IBOutlet weak var toxicityImageView: UIImageView!
    @IBOutlet weak var toxicityLabel: UILabel!
    
    
    override func awakeFromNib() {
        setupView()
    }
    
    
    override func prepareForReuse() {
        thumbImage.image = nil
    }
    

    func configureCell(withMushroom mushroom: Mushroom) {
        mainTitle.text = mushroom.vernacularName_dk?.vernacularname_dk
        secondaryTitle.text = mushroom.vernacularName_dk?.appliedLatinName
        dkAmount.text = String(describing: mushroom.statistics!.accepted_count)
        
        downloadThumbImage(url: mushroom.images[0]!.thumburi)
        
        guard let toxicityLevel = mushroom.toxicityLevel else {toxicityLevelStackView.isHidden = true; return}
        toxicityLevelStackView.isHidden = false
        toxicityLabel.text = toxicityLevel.rawValue
        switch toxicityLevel {
        case .eatable:
            toxicityLabel.textColor = UIColor.appGreen()
        case .toxic:
            toxicityLabel.textColor = UIColor.appRed()
        case .cautious:
            toxicityLabel.textColor = UIColor.appYellow()
        }
        
        
    }
    
    private func downloadThumbImage(url: String) {
        DataService.instance.getThumbImageForMushroom(url: url) { (image) in
            DispatchQueue.main.async {
                self.thumbImage.image = image
            }
        }
    }
    
    
    private func setupView() {
        mainTitle.font = UIFont.appHeaderDetails()
        secondaryTitle.font = UIFont.appPrimary()
        dkAmountTitle.font = UIFont.appText()
        dkLatestTitle.font = UIFont.appText()
        dkAmount.font = UIFont.appTextHighlight()
        dkLatest.font = UIFont.appTextHighlight()
        
        dkAmountTitle.text = "Antal danske fund:"
        dkLatestTitle.text = "Seneste danske fund:"
        
        
        mainTitle.adjustsFontSizeToFitWidth = true
        secondaryTitle.adjustsFontSizeToFitWidth = true
        
        toxicityLabel.font = UIFont.appBold()
//        toxicityLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
