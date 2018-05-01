//
//  MushroomAnnotationView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit


class ObservationPin: NSObject, MKAnnotation {
    var observation: Observation
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, observation: Observation) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.observation = observation
        super.init()
    }
}

class ObservationPinView: MKAnnotationView {

    lazy var calloutView: ObservationPinCalloutView = {
        let view = ObservationPinCalloutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
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
    
    private var observationPin: ObservationPin?
    
    init(annotation: ObservationPin, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        observationPin = annotation
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
//        imageView.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
//        imageView.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
//        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        imageView.frame.origin.y = 0
        
        
        
       imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
       imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2).isActive = true
       imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.image = #imageLiteral(resourceName: "agaricus-arvensis1")
//        guard let url = mushroom?.images![0].thumburi else {return}
//
//        DataService.instance.getThumbImageForMushroom(url: url) { (image) in
//           self.imageView.image = image
//
//        }
        
        if #available(iOS 11.0, *) {
//            displayPriority = .defaultHigh
//            collisionMode = .circle
            clusteringIdentifier = "clusterAnnotationView"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            addSubview(calloutView)
            calloutView.setupConstraints(imageView: imageView)
                calloutView.configureCalloutView(image: #imageLiteral(resourceName: "agaricus-arvensis1"), title: "Chanterelle", subtitle: "Cantharellus cibarius")
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
