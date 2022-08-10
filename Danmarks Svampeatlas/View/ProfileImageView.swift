//
//  ProfileImageView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {
    
    private var imageView: DownloadableImageView = {
       let imageView = DownloadableImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(UILayoutPriority(249), for: NSLayoutConstraint.Axis.vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(249), for: NSLayoutConstraint.Axis.horizontal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var defaultImage: UIImage?
    
    override var clipsToBounds: Bool {
        didSet {
            imageView.clipsToBounds = clipsToBounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        imageView.layer.cornerRadius = frame.height / 2
    }
    
    init(defaultImage: UIImage?) {
        self.defaultImage = defaultImage
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 2.0
        
        backgroundColor = UIColor.appPrimaryColour()
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    func reset() {
        imageView.image = nil
        imageView.alpha = 1
        label.text = ""
    }
    
    func configure(image: UIImage) {
        imageView.image = image
        imageView.alpha = 1
        label.text = ""
    }
    
    func configure(initials: String?, imageURL: String?, imageSize: DataService.ImageSize) {
        imageView.image = nil
        
            if let imageURL = imageURL {
                imageView.alpha = 0.7
                imageView.downloadImage(size: imageSize, urlString: imageURL)
            } else {
                imageView.image = nil
                imageView.alpha = 0.0
            }
            
            if let initials = initials, initials != "" {
                label.text = initials.uppercased()
            } else {
                imageView.alpha = 1.0
            }
        }
}
