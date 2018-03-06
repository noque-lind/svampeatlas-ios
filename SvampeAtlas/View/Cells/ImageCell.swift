//
//  ImageCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        authorGradient.frame = authorGradientView.bounds
    }
    
    
   lazy var authorGradient: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        gradient.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
        return gradient
    }()
    
    lazy var authorGradientView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.addSublayer(authorGradient)
        return view
    }()
    
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    func configureCell(url: String, photoAuthor: String) {
        authorLabel.text = photoAuthor
        DataService.instance.getThumbImageForMushroom(url: url) { (image) in
            DispatchQueue.main.async {
                self.image.image = image
            }
        }
    }
    
    private func setupView() {
        authorLabel.font = UIFont.appText(customSize: 12)
        authorLabel.textColor = UIColor.white
        setupAuthorGradient()
        
        
    }
    
    private func setupAuthorGradient() {
        insertSubview(authorGradientView, belowSubview: authorLabel)
        authorGradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        authorGradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        authorGradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        authorGradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        authorGradientView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
