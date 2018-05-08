//
//  Observation.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct Observation: Decodable {
    public private(set) var geom: Geom?
    public private(set) var determinationView: DeterminationView?
    public private(set) var observedBy: String?
    public private(set) var observationDate: String?
    public private(set) var locality: Locality?
    
    private enum CodingKeys: String, CodingKey {
        case geom = "geom"
        case determinationView = "DeterminationView"
        case observedBy = "verbatimLeg"
        case observationDate = "observationDate"
        case locality = "Locality"
        
    }
}

struct Geom: Decodable {
    public private(set) var coordinates: [Double]
}

struct DeterminationView: Decodable {
    public private(set) var taxon_id: Int?
    public private(set) var taxon_latinName: String?
    public private(set) var taxon_danishName: String?
    public private(set) var redlistStatus: String?
    
    private enum CodingKeys: String, CodingKey {
        case taxon_id = "Taxon_id"
        case taxon_latinName = "Taxon_FullName"
        case taxon_danishName = "Taxon_vernacularname_dk"
        case redlistStatus = "Taxon_redlist_status"
    }
}

struct Locality: Decodable {
    public private(set) var name: String
}
