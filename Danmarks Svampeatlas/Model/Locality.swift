//
//  Locality.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 23/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

struct Locality: Decodable, Encodable, Equatable {
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
    
    var fullName: String {
        get {
            if let geoName = geoName {
                return "\(geoName.countryName), \(geoName.name)"
            } else {
                return name
            }
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

extension Locality {
    init?(_ cdNote: CDLocality) {
        guard let name = cdNote.name else {return nil}
        self.id = Int(cdNote.id)
        self.name = name
        self.latitude = cdNote.latitude
        self.longitude = cdNote.longitude
        self.geoName = nil
    }
    
    func toCD(context: NSManagedObjectContext) -> CDLocality {
        (NSEntityDescription.insertNewObject(forEntityName: "CDLocality", into: context) as! CDLocality).then({
            $0.id = Int32(id)
            $0.name = name
            $0.latitude = latitude
            $0.longitude = longitude
        })
    }
}
