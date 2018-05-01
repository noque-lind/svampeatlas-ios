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
    
    private var observationPins: [ObservationPin] {
        get {
            return (annotation as! MKClusterAnnotation).memberAnnotations as! [ObservationPin]
        }
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) {
            return parentHitView
            } else {
                return calloutView.hitTest(convert(point, to: calloutView), with: event)
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
            calloutView.setupConstraints(superView: self)
            calloutView.configureCalloutView(observationPins: observationPins)
             calloutView.show()
        } else {
            calloutView.hide(superView: self, animated: animated)
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
