//
//  MushroomThumbImage.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class RoundedImageView: UIView {

    private lazy var imageView: DownloadableImageView = {
       let imageView = DownloadableImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var isMasked: Bool = true {
        didSet {
            imageView.clipsToBounds = isMasked
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func setupView() {
        clipsToBounds = true
        layer.shadowOpacity = Float.shadowOpacity()
        layer.cornerRadius = CGFloat.cornerRadius()
        layer.shadowOffset = CGSize.shadowOffset()
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
        

    func configureImage(url: String?) {
            imageView.image = nil
        imageView.downloadImage(size: .mini, urlString: url)
        }
    
    func configureImage(image: UIImage) {
        imageView.image = image
    }
    
    func configureRoundness(fullyRounded: Bool) {
        if !fullyRounded {
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
}
