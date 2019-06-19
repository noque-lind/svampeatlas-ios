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
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private var calloutView: ClusterPinCalloutView?
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
            calloutView = nil
        } didSet {
            if let annotations = annotation as? MKClusterAnnotation {
                countLabel.text = "\(annotations.memberAnnotations.count)"
                
            }
        }
    }
    
    
    private lazy var observations: [Observation] = {
            let observations = ((annotation as! MKClusterAnnotation).memberAnnotations as! [ObservationPin]).compactMap({$0.observation})
            return observations
    }()
    
    var showObservation: ((_ observation: Observation) -> ())?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
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
    
    private func setupView() {
        displayPriority = .required
        collisionMode = .circle
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
            
            let calloutView: ClusterPinCalloutView = {
                let view = ClusterPinCalloutView(showObservation: showObservation)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.calloutView = calloutView
            addSubview(self.calloutView!)
            calloutView.configure(superView: self, observations: observations)
            calloutView.show()
        } else {
            calloutView?.hide(superView: self, animated: animated, completion: {
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
