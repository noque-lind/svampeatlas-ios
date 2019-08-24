//
//  Locality.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 23/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import CoreLocation

struct Locality: Decodable, Equatable {
    static func == (lhs: Locality, rhs: Locality) -> Bool {
        if lhs.id == rhs.id {return true} else {return false}
    }
    
    public private(set) var id: Int
    public private(set) var name: String
    public private(set) var latitude: Double
    public private(set) var longitude: Double
    public private(set) var geoName: GeoName?
    
    public var location: CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case longitude = "decimalLongitude"
        case latitude = "decimalLatitude"
        case geoName
    }
}
