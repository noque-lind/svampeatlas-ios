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
    var determinationView: PrivateDeterminationView?
    var primaryDetermination: PrivatePrimaryDeterminationView?
    var images: [PrivateImages]?
    var primaryUser: PrivatePrimaryUser?
    var locality: PrivateLocality?
    var geoNames: PrivateGeoName?
    var forum: [PrivateForum]?
    var vegetationtype_id: Int?
    var substrate_id: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case observationDate
        case ecologyNote = "ecologynote"
        case geom
        case determinationView = "DeterminationView"
        case images = "Images"
        case primaryUser = "PrimaryUser"
        case locality = "Locality"
        case note
        case primaryDetermination = "PrimaryDetermination"
        case forum = "Forum"
        case vegetationtype_id
        case substrate_id
        case geoNames = "GeoNames"
    }
}

fileprivate struct PrivateGeom: Decodable {
    var coordinates: [Double]
}

fileprivate struct PrivateDeterminationView: Decodable {
    public private(set) var taxon_id: Int?
    public private(set) var taxon_FullName: String?
    public private(set) var taxon_vernacularname_dk: String?
    public private(set) var redlistStatus: String?
    public private(set) var determination_validation: String?
    
    private enum CodingKeys: String, CodingKey {
        case taxon_id
        case taxon_vernacularname_dk
        case taxon_FullName
        case redlistStatus
        case determination_validation
    }
}

fileprivate struct PrivatePrimaryDeterminationView: Decodable {
    public private(set) var validation: String?
    public private(set) var Taxon: PrivateTaxon
}
fileprivate struct PrivateTaxon: Decodable {
    public private(set) var acceptedTaxon: PrivateAcceptedTaxon
}

fileprivate struct PrivateAcceptedTaxon: Decodable {
    public private(set) var _id: Int?
    public private(set) var FullName: String?
    public private(set) var Vernacularname_DK: Vernacularname_DK?
}

fileprivate struct Vernacularname_DK: Decodable {
    public private(set) var vernacularname_dk: String
}

fileprivate struct PrivateImages: Decodable {
    var name: String
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
    var facebook: String?
}

fileprivate struct PrivateLocality: Decodable {
    var name: String?
    var kommune: String?
}

fileprivate struct PrivateForum: Decodable {
    var _id: Int?
    var createdAt: String?
    var content: String?
    var User: PrivateProfile?
}

private struct PrivateGeoName: Decodable {
    var geonameId: Int
    var name: String
    var countryName: String
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
    public private(set) var comments = [Comment]()
    public private(set) var validationStatus: String?
    public private(set) var substrate: Substrate?
    public private(set) var vegetationType: VegetationType?
    
    init(from decoder: Decoder) throws {
        let privateObservation = try PrivateObservation(from: decoder)
        id = privateObservation.id
        coordinates = privateObservation.geom.coordinates
        date = privateObservation.observationDate
        observedBy = privateObservation.primaryUser?.profile?.name
        note = privateObservation.note
        ecologyNote = privateObservation.ecologyNote
        
        if let geomNames = privateObservation.geoNames {
            location = "\(geomNames.countryName), \(geomNames.name)"
        } else {
            location = privateObservation.locality?.name
        }
        
        if let vegetationTypeID = privateObservation.vegetationtype_id {
            vegetationType = CoreDataHelper.fetchVegetationType(withID: vegetationTypeID)
        }
        
        if let substrateID = privateObservation.substrate_id {
            substrate = CoreDataHelper.fetchSubstrateGroup(withID: substrateID)
        }
        
        if let determinationView = privateObservation.determinationView {
            validationStatus = determinationView.determination_validation
            
            speciesProperties = SpeciesProperties(id: determinationView.taxon_id ?? 0, name: determinationView.taxon_vernacularname_dk ?? determinationView.taxon_FullName ?? "")
        
        } else if let primaryDeterminationView = privateObservation.primaryDetermination {
            speciesProperties = SpeciesProperties(id: primaryDeterminationView.Taxon.acceptedTaxon._id ?? 0, name: primaryDeterminationView.Taxon.acceptedTaxon.Vernacularname_DK?.vernacularname_dk ?? primaryDeterminationView.Taxon.acceptedTaxon.FullName ?? "")
        } else {
            speciesProperties = SpeciesProperties(id: id, name: "")
        }
        
        if let privateObservationImages = privateObservation.images {
            for privateImage in privateObservationImages {
                if images == nil {
                    images = [Image]()
                }
                images?.append(Image(thumbURL: nil, url: privateImage.url, photographer: observedBy))
            }
        }
        
        if let privateForums = privateObservation.forum {
            for privateForum in privateForums {
                guard let id = privateForum._id, let createdAt = privateForum.createdAt, let content = privateForum.content, let commenterName = privateForum.User?.name else {continue}
                comments.append(Comment(id: id, date: createdAt, content: content, commenterName: commenterName, initials: privateForum.User?.Initialer, commenterFacebookID: privateForum.User?.facebook))
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

struct Comment: Decodable {
    public private(set) var id: Int
    public private(set) var date: String
    public private(set) var content: String
    public private(set) var commenterName: String
    public private(set) var initials: String?
    private(set) var commenterFacebookID: String?
    
    public var commenterProfileImageURL: String? {
        if let commenterFacebookID = commenterFacebookID {
            return "https://graph.facebook.com/\(commenterFacebookID)/picture?width=70&height=70"
        } else {
            return nil
        }
    }
}

func == (lhs: Observation, rhs: Observation) -> Bool {
    if lhs.id == rhs.id {
        return true
    } else {
        return false
    }
}