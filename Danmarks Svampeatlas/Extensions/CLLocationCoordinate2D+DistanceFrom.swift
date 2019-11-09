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
    
    fileprivate func toRadians(angleInDegress: Double) -> Double {
        return angleInDegress * Double.pi / 180
    }
    
    fileprivate func toDegress(angleInRadians: Double) -> Double {
        return angleInRadians * 180 / Double.pi
    }
    
    func toCirclePolygon(radius: Double, numberOfSegments: Int = 15) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        let latitudeInRadians =  toRadians(angleInDegress: self.latitude)
        let longitudeInRadians = toRadians(angleInDegress: self.longitude)
        let radiusDividedByEathRadius = radius / 6378137
    
        while coordinates.count < numberOfSegments {
            let bearing = 2 * Double.pi * Double(coordinates.count) / Double(numberOfSegments)
            let offsetLangitude = asin((sin(latitudeInRadians) * cos(radiusDividedByEathRadius)) + cos(latitudeInRadians) * sin(radiusDividedByEathRadius) * cos(bearing))
            let offsetLongitude = longitudeInRadians + atan2(sin(bearing) * sin(radiusDividedByEathRadius) * cos(latitudeInRadians), cos(radiusDividedByEathRadius) - sin(latitudeInRadians) * sin(offsetLangitude))
            
    
            coordinates.append(CLLocationCoordinate2D(latitude: toDegress(angleInRadians: offsetLangitude), longitude: toDegress(angleInRadians: offsetLongitude)))
        }
        
        
        
        
        coordinates.append(coordinates[0])
        return coordinates
    }
    
    func toRectanglePolygon(radius: Double) -> [CLLocationCoordinate2D] {
        let region = MKCoordinateRegion(center: self, latitudinalMeters: radius, longitudinalMeters: radius)
        
        let latitudeDelta = region.span.latitudeDelta / 2
        let longitudeDelta = region.span.longitudeDelta / 2
        
        var coordinates = [CLLocationCoordinate2D]()
        coordinates.append(CLLocationCoordinate2D(latitude: self.latitude - latitudeDelta, longitude: self.longitude - longitudeDelta))
        
        coordinates.append(CLLocationCoordinate2D(latitude: self.latitude - latitudeDelta, longitude: self.longitude + longitudeDelta))
        
        coordinates.append(CLLocationCoordinate2D(latitude: self.latitude + latitudeDelta, longitude: self.longitude + longitudeDelta))
        
        coordinates.append(CLLocationCoordinate2D(latitude: self.latitude + latitudeDelta, longitude: self.longitude - longitudeDelta))
        
        coordinates.append(coordinates[0])
        return coordinates
    }

}



