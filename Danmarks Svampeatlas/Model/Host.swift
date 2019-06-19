//
//  Host.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 23/05/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct Host: Decodable, Equatable {
    public private(set) var id: Int
    public private(set) var dkName: String?
    public private(set) var latinName: String?
    public private(set) var probability: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case dkName = "DKname"
        case latinName = "LatinName"
        case probability
    }
    
     init(from cdHost: CDHost) {
        self.id = Int(cdHost.id)
        self.dkName = cdHost.dkName ?? ""
        self.latinName = cdHost.latinName ?? ""
        self.probability = Int(cdHost.probability)
    }

}
