//
//  MushroomAnnotationView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit


class MushroomPin: NSObject, MKAnnotation {
    var mushroom: Mushroom?
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, mushroom: Mushroom?) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.title = "Mushroom"
        self.subtitle = "Mdjkcd"
        self.mushroom = mushroom
        super.init()
    }
    
    
    
}

class MushroomAnnotationView: MKAnnotationView {
    
    var mushroom: Mushroom?
    
    lazy var calloutView: CalloutView = {
        let view = CalloutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "IMG_15270")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView.removeFromSuperview()
        }
    }
    
    init(annotation: MushroomPin, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.mushroom = annotation.mushroom
        setupView()
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    
    
    private func setupView() {
        canShowCallout = false
        self.image = #imageLiteral(resourceName: "MushroomPin")
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            addSubview(calloutView)
            calloutView.setupConstraints(imageView: imageView)
                calloutView.configureCalloutView(image: #imageLiteral(resourceName: "IMG_15270"), title: "Chanterelle", subtitle: "Cantharellus cibarius")
             calloutView.show(imageView: imageView)
        } else {
            calloutView.hide(animated: animated)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView.removeFromSuperview()
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
