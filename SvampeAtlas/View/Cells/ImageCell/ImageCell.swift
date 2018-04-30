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
        gradient.frame = image.bounds
    }
    
    
   lazy var gradient: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0.8)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.frame = image.bounds
        return gradient
    }()
    
    lazy var authorGradientView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.addSublayer(gradient)
        return view
    }()
    
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    func configureCell(url: String, photoAuthor: String) {
        authorLabel.text = photoAuthor
        DataService.instance.getImage(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.image.image = image
            }
        }
    }
    
    private func setupView() {
        authorLabel.font = UIFont.appText(customSize: 12)
        authorLabel.textColor = UIColor.white
        setupAuthorGradient()
//        image.layer.mask = gradient
    }
    
    private func setupAuthorGradient() {
//       image.addSubview(authorGradientView)
//        authorGradientView.leadingAnchor.constraint(equalTo: image.leadingAnchor).isActive = true
//        authorGradientView.trailingAnchor.constraint(equalTo: image.trailingAnchor).isActive = true
//        authorGradientView.bottomAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
//        authorGradientView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
