//
//  ResultCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeaderDetails()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    lazy var confidenceLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    lazy var textStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(confidenceLabel)
        return stackView
    }()
    
    lazy var contentStackView: UIStackView = {
      let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(thumbImageView)
        stackView.addArrangedSubview(textStackView)
        return stackView
    }()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        thumbImageView.layer.cornerRadius = thumbImageView.frame.height / 2
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
    
    
    
    
    func configureCell(name: String, confidence: CGFloat) {
        nameLabel.text = name
        confidenceLabel.text = "\(Int(confidence * 100))% sikker"
        thumbImageView.image = #imageLiteral(resourceName: "IMG_15270")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
