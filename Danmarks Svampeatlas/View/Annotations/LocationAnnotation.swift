//
//  LocationAnnotation.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 07/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit.MKAnnotation
import MapKit.MKAnnotationView

class LocationPIn: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = NSLocalizedString("locationAnnotation_title", comment: "")
    }
}

class LocationAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        displayPriority = .required
        image = #imageLiteral(resourceName: "Icons_MenuIcons_Location").colorized(color: UIColor.appPrimaryColour())
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        layer.shadowOpacity = Float.shadowOpacity()
        layer.shadowOffset = CGSize.shadowOffset()
        tintColor = UIColor.appPrimaryColour()
        canShowCallout = true
    }
}
