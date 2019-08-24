//
//  Substrate.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//



struct SubstrateGroup {
    
    public private(set) var id: Int = 100
    public private(set) var dkName: String
    public private(set) var enName: String
    public private(set) var substrates = [Substrate]()
    
    init(from cdSubstrateGroup: CDSubstrateGroup) {
        self.dkName = cdSubstrateGroup.dkName ?? ""
        self.enName = cdSubstrateGroup.enName ?? ""
        guard let cdSubstrates = cdSubstrateGroup.cdSubstrate?.allObjects as? [CDSubstrate] else {return}
        self.substrates = cdSubstrates.compactMap({Substrate(from: $0)})
        self.assignID()
        }
    
    init(dkName: String, enName: String, substrates: [Substrate]) {
        self.dkName = dkName
        self.enName = enName
        self.substrates = substrates
        self.assignID()
    }
    
    mutating func appendSubstrate(substrate: Substrate) {
        substrates.append(substrate)
    }
    
    mutating private func assignID() {
        switch dkName {
        case "jord":
            id = 0
        case "ved":
            id = 1
        case "plantemateriale":
            id = 2
        case "mosser":
            id = 3
        case "dyr":
            id = 4
        case "svampe og svampedyr":
            id = 5
        case "sten":
            id = 6
        
        default:
            id = 100
        }
    }
    }
    

struct Substrate {
    public private(set) var id: Int
    public private(set) var dkName: String
    public private(set) var enName: String
    public var isLocked: Bool = false
    
    init(from cdSubstrate: CDSubstrate) {
        self.id = Int(cdSubstrate.id)
        self.dkName = cdSubstrate.dkName ?? ""
        self.enName = cdSubstrate.enName ?? ""
    }
    
    init(id: Int, dkName: String, enName: String) {
        self.id = id
        self.dkName = dkName
        self.enName = enName
    }
}