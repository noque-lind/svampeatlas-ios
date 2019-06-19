//
//  MushroomThumbImage.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DownloadableImageView: UIImageView {
    private var urlString: String?
    
    func downloadImage(size: DataService.imageSize, urlString: String?) {
        self.urlString = urlString
        guard let urlString = urlString else {return}
        DataService.instance.getImage(forUrl: urlString, size: size) { (image, url) in
            if self.urlString == urlString {
                DispatchQueue.main.async { [weak self] in
                    self?.fadeToNewImage(image: image)
                    self?.image = image
                }
            }
        }
    }
}


class RoundedImageView: UIView {

    private lazy var imageView: DownloadableImageView = {
       let imageView = DownloadableImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
//        imageView.layer.mask = shapeLayer
        return imageView
    }()
    
    private let shapeLayer = CAShapeLayer()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        round()
    }
    
    private func setupView() {
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowPath = shapeLayer.path
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    private func round() {
        layer.cornerRadius = frame.height / 2 - 7
        let radius = frame.height / 2 - 7
        
        shapeLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        }
        

    func configureImage(url: String?) {
            imageView.image = nil
        imageView.downloadImage(size: .mini, urlString: url)
        }
    
    func configureImage(image: UIImage) {
        self.imageView.image = image
    }
}
