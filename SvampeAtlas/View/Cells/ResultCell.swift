//
//  ResultCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appPrimaryColour()
        view.addSubview(thumbImageView)
        thumbImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        thumbImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        thumbImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        return view
    }()
    
    
    lazy var thumbImageView: RoundedImageView = {
        let imageView = RoundedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    lazy var confidenceLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    lazy var textStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(confidenceLabel)
        return stackView
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupView() {
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        tintColor = UIColor.appWhite()
        backgroundColor = UIColor.clear
        
        insertSubview(backgroundContainerView, at: 0)
        backgroundContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        backgroundContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        contentView.addSubview(textStackView)
        textStackView.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 16).isActive = true
        textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        textStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16).isActive = true
        textStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16).isActive = true
    }
    
    func configureCell(name: String, confidence: CGFloat) {
        nameLabel.text = name
        confidenceLabel.text = "\(Int(confidence * 100))% sikker"
        thumbImageView.configureImage(url: nil)
    }
}
