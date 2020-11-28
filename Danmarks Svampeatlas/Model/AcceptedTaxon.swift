//
//  AcceptedTaxon.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 08/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct AcceptedTaxon: Decodable {
    public private(set) var id: Int
    public private(set) var fullName: String
    public private(set) var vernacularNameDK: VernacularNameDK?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "FullName"
        case vernacularNameDK = "Vernacularname_DK"
    }
    
}
