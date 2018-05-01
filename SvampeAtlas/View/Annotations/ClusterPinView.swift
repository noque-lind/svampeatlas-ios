//
//  MushroomAnnotationView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

@available(iOS 11.0, *)
class ClusterPinView: MKAnnotationView {
    
    lazy var calloutView: ClusterPinCalloutView = {
        let view = ClusterPinCalloutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var countLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let cluster = newValue as? MKClusterAnnotation else {return}
            countLabel.text = "\(cluster.memberAnnotations.count)"
        }
    }
    
    private var observations: [Observation] {
        get {
            var observations = [Observation]()
            for observationPin in (annotation as! MKClusterAnnotation).memberAnnotations as! [ObservationPin] {
                observations.append(observationPin.observation)
            }
            return observations
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
    
    init(annotation: MKClusterAnnotation, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            displayPriority = .defaultHigh
            collisionMode = .circle
        setupView()
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    

    private func setupView() {
        canShowCallout = false
        self.image = #imageLiteral(resourceName: "ClusterPin")
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
    
        addSubview(countLabel)
        countLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        countLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            addSubview(calloutView)
            calloutView.configure(superView: self, observations: observations)
            calloutView.show()
        } else {
            calloutView.hide(superView: self, animated: animated)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView.removeFromSuperview()
    }
}
