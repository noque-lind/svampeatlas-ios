//
//  Substrate.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//



class SubstrateGroup {
    
    public private(set) var dkName: String
    public private(set) var enName: String
    public private(set) var substrates = [Substrate]()
    
    init(from cdSubstrateGroup: CDSubstrateGroup) {
        self.dkName = cdSubstrateGroup.dkName ?? ""
        self.enName = cdSubstrateGroup.enName ?? ""
        
        guard let cdSubstrates = cdSubstrateGroup.cdSubstrate?.allObjects as? [CDSubstrate] else {return}
        self.substrates = cdSubstrates.compactMap({Substrate(from: $0)})
        }
    
    init(dkName: String, enName: String, substrates: [Substrate]) {
        self.dkName = dkName
        self.enName = enName
        self.substrates = substrates
    }
    
    func appendSubstrate(substrate: Substrate) {
        substrates.append(substrate)
    }
    }
    

class Substrate {
    public private(set) var id: Int
    public private(set) var dkName: String
    public private(set) var enName: String
    
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
