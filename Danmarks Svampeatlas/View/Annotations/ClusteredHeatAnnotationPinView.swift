//
//  ClusteredHeatAnnotationPinView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 28/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import MapKit.MKClusterAnnotation
import MapKit.MKAnnotationView

class ClusteredHeatAnnotation: MKClusterAnnotation {
    var image: UIImage {
        get {
            switch memberAnnotations.count {
            case 1:
                return UIImage(named: "Icons_Map_Cluster1")!
            case 1...9:
                return UIImage(named: "Icons_Map_Cluster1.9")!
            case 10...30:
                return UIImage(named: "Icons_Map_Cluster10.30")!
            case 30...50:
                return UIImage(named: "Icons_Map_Cluster30.50")!
            default:
                return UIImage(named: "Icons_Map_Cluster50")!
            }
        }
    }
}


class ClusteredHeatAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            if let annotation = annotation as? ClusteredHeatAnnotation {
                configure(annotation: annotation)
            }
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
        displayPriority = .required
        collisionMode = .circle
        canShowCallout = false
    }
    
    private func configure(annotation: ClusteredHeatAnnotation) {
        self.image = annotation.image
    }
}
