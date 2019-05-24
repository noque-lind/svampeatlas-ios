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
    var detailed: Bool
    var observation: Observation
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, observation: Observation, detailed: Bool) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.observation = observation
        self.detailed = detailed
        super.init()
    }
}


class ObservationPinView: MKAnnotationView {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderColor = UIColor.appPrimaryColour().cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()
    
    private var calloutView: ObservationPinCalloutView?
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
            calloutView = nil
        }   didSet {
            if annotation != nil {
                configure()
            }
        }
    }
    
    private var observationPin: ObservationPin {
        get {
            return annotation as! ObservationPin
        }
    }
    
    var wasPressed: ((_ observation: Observation) -> ())?
    
    private var withImage: Bool
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, withImage: Bool) {
        self.withImage = withImage
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isSelected {
            guard let result = calloutView?.hitTest(convert(point, to: calloutView), with: event) else {return nil}
            return result
        } else {
            return nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if withImage {
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
    }
    
    private func setupView() {
        canShowCallout = false
        displayPriority = .required
        collisionMode = .rectangle
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        if withImage {
            self.image = #imageLiteral(resourceName: "SinglePin")
            self.addSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).isActive = true
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        } else {
            self.image = #imageLiteral(resourceName: "SinglePinNoImage")
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func configure() {
        imageView.image = nil
        guard let imageURL = observationPin.observation.images?.first?.url else {return}
        DataService.instance.getImage(forUrl: imageURL, size: .mini) { (image, imageURL) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            calloutView = ObservationPinCalloutView(withImage: withImage, wasPressed: wasPressed)
            addSubview(calloutView!)
            calloutView!.translatesAutoresizingMaskIntoConstraints = false
            if withImage {
                calloutView!.configure(imageView: imageView, observation: observationPin.observation)
            } else {
                calloutView!.configure(imageView: nil, observation: observationPin.observation)
                calloutView!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4).isActive = true
                calloutView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
            }
            calloutView!.show()
        } else {
            calloutView?.hide(animated: animated, completion: {
                self.calloutView?.removeFromSuperview()
                self.calloutView = nil
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView?.removeFromSuperview()
        calloutView = nil
    }
}
