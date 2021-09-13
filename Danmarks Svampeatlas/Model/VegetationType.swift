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
    let dkName: String
    let enName: String
    let czName: String?
    public var isLocked: Bool = false
    
    var name: String {
        switch Utilities.appLanguage() {
        case .czech: return czName ?? enName
        case .danish: return dkName
        case .english: return enName
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case dkName = "name"
        case enName = "name_uk"
        case czName = "name_cz"
    }
    
    init(from cdVegetationType: CDVegetationType) {
        self.id = Int(cdVegetationType.id)
        self.dkName = cdVegetationType.dkName ?? ""
        self.enName = cdVegetationType.enName ?? ""
        self.czName = cdVegetationType.czName
    }
    
    init(id: Int, dkName: String, enName: String, czName: String?) {
        self.id = id
        self.dkName = dkName
        self.enName = enName
        self.czName = czName
    }
}
