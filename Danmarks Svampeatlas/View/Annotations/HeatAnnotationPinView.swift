//
//  HeatAnnotationPinView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 28/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit.MKAnnotation
import MapKit.MKAnnotationView

class HeatAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        image = UIImage(named: "Icons_Map_Cluster1")!
        canShowCallout = false
        displayPriority = .defaultHigh
        collisionMode = .circle
    }
}
