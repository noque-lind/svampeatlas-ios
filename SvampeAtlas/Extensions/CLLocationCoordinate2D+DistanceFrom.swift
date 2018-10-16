//
//  CLLocationCoordinate2D+DistanceFrom.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}



