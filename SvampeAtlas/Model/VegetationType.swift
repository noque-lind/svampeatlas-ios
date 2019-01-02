//
//  VegetationType.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 25/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct VegetationType: Decodable {
    public private(set) var id: Int
    public private(set) var dkName: String
    public private(set) var enName: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case dkName = "name"
        case enName = "name_uk"
    }
}
