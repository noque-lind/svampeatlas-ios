//
//  LocalityAnnotationView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class LocalityAnnotation: NSObject, MKAnnotation {
   
    public private(set) var coordinate: CLLocationCoordinate2D
    public private(set) var identifier: String
    public private(set) var locality: Locality
    
    init(coordinate: CLLocationCoordinate2D, identifier: String, locality: Locality) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.locality = locality
        super.init()
    }
}

class LocalityAnnotationView: MKAnnotationView {
    
    override var isSelected: Bool {
        didSet {
            self.image = isSelected ? #imageLiteral(resourceName: "Selected"): #imageLiteral(resourceName: "DeSelected")
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        canShowCallout = false
        self.image = #imageLiteral(resourceName: "DeSelected")
}
}
