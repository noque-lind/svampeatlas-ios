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
        imageView.image = #imageLiteral(resourceName: "agaricus-arvensis1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView.removeFromSuperview()
        }
    }
    
    private var observationPin: ObservationPin {
        get {
            return annotation as! ObservationPin
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isSelected {
            guard let result = calloutView.hitTest(convert(point, to: calloutView), with: event) else {return nil}
            return result
        } else {
            return nil
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches moved inside observationPINVIEW")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began inside observervationPINVIEw")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
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
       imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
       imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1).isActive = true
       imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
//        if #available(iOS 11.0, *) {
////            displayPriority = .defaultHigh
////            collisionMode = .circle
//            clusteringIdentifier = "clusterAnnotationView"
//        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            addSubview(calloutView)
            calloutView.setupConstraints(imageView: imageView)
                calloutView.configureCalloutView(observation: observationPin.observation)
             calloutView.show(imageView: imageView)
        } else {
            calloutView.hide(animated: animated)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView.removeFromSuperview()
    }
}
