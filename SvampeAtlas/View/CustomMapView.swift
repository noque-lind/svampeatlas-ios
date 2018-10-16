//
//  CustomMapView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 01/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class CustomMapView: MKMapView {
//    var selectedAnnotationView: ObservationPinView?
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
        return false
        }
    }
}
