//
//  Observation.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

fileprivate struct PrivateObservation: Decodable {
    var id: Int
    var observationDate: String
    var ecologyNote: String?
    var note: String?
    var geom: PrivateGeom
    var determinationView: PrivateDeterminationView
    var images: [PrivateImages]?
    var primaryUser: PrivatePrimaryUser?
    var locality: PrivateLocality?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case observationDate
        case ecologyNote
        case geom
        case determinationView = "DeterminationView"
        case images = "Images"
        case primaryUser = "PrimaryUser"
        case locality = "Locality"
        case note
    }
}

fileprivate struct PrivateGeom: Decodable {
    var coordinates: [Double]
}

fileprivate struct PrivateDeterminationView: Decodable {
    public private(set) var taxon_id: Int
    public private(set) var taxon_FullName: String?
    public private(set) var taxon_vernacularname_dk: String?
    public private(set) var redlistStatus: String?
    public private(set) var determinationValidation: String?
    
    private enum CodingKeys: String, CodingKey {
        case taxon_id = "Taxon_id"
        case taxon_vernacularname_dk = "Taxon_vernacularname_dk"
        case taxon_FullName = "Taxon_FullName"
    }
}

fileprivate struct PrivateImages: Decodable {
    private var name: String
    var createdAt: String
    var url: String {
        get {
            return "https://svampe.databasen.org/uploads/" + name + ".JPG"
        }
    }
}

fileprivate struct PrivatePrimaryUser: Decodable {
    var profile: PrivateProfile?
}

fileprivate struct PrivateProfile: Decodable {
    var name: String?
    var Initialer: String?
}

fileprivate struct PrivateLocality: Decodable {
    var name: String?
    var kommune: String?
}

// Front

struct Observation: Decodable, Equatable {
    public private(set) var id: Int
    public private(set) var coordinates: [Double]
    public private(set) var speciesProperties: SpeciesProperties
    public private(set) var date: String?
    public private(set) var observedBy: String?
    public private(set) var note: String?
    public private(set) var ecologyNote: String?
    public private(set) var location: String?
    public private(set) var images: [Image]?
    
    init(from decoder: Decoder) throws {
        let privateObservation = try PrivateObservation(from: decoder)
        id = privateObservation.id
        coordinates = privateObservation.geom.coordinates
        date = privateObservation.observationDate
        observedBy = privateObservation.primaryUser?.profile?.name
        note = privateObservation.note
        ecologyNote = privateObservation.ecologyNote
        location = privateObservation.locality?.name
        speciesProperties = SpeciesProperties(id: privateObservation.determinationView.taxon_id, name: privateObservation.determinationView.taxon_vernacularname_dk ?? privateObservation.determinationView.taxon_FullName ?? "")
        
        
        if let privateObservationImages = privateObservation.images {
            for privateImage in privateObservationImages {
                if images == nil {
                    images = [Image]()
                }
                images?.append(Image(thumbURL: nil, url: privateImage.url, photographer: observedBy))
            }
            
        }
    }
}

struct SpeciesProperties: Decodable {
    public private(set) var id: Int
    public private(set) var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name.capitalizeFirst()
    }
}

func == (lhs: Observation, rhs: Observation) -> Bool {
    if lhs.id == rhs.id {
        return true
    } else {
        return false
    }
}
