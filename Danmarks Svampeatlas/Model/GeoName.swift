//
//  GeoName.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 09/08/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class GeoNames: Decodable, Encodable {
    public private(set) var geonames: [GeoName]
    
}

struct GeoName: Decodable, Encodable {
    var geonameId: Int
    var name: String
    var countryName: String
    var adminName1: String
    var lat: String
    var lng: String
    var countryCode: String
    var fcodeName: String
    var fclName: String
}
