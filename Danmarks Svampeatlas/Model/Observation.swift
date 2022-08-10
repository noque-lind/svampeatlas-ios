//
//  Observation.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import MapKit.MKTypes

private struct PrivateObservation: Decodable {
    var id: Int
    var createdAt: String
    var observationDate: String
    var ecologyNote: String?
    var note: String?
    var geom: PrivateGeom
    var determinationView: PrivateDeterminationView?
    var primaryDetermination: PrivatePrimaryDeterminationView?
    var images: [PrivateImages]?
    var primaryUser: PrivatePrimaryUser?
    var locality: PrivateLocality?
    var geoNames: PrivateGeoNames?
    var forum: [PrivateForum]?
    var vegetationtype_id: Int?
    var substrate_id: Int?
    var accuracy: Int?
    let os: String?
    let browser: String?
    let associatedTaxa: [PrivateAssociatedTaxa]?
    let Substrate: PrivateSubstrate?
    let VegetationType: PrivateVegetationType?
    
    private enum CodingKeys: String, CodingKey {
        case createdAt
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
        case accuracy
        case os
        case browser
        case associatedTaxa
        case VegetationType
        case Substrate
        
    }
}

private struct PrivateGeoNames: Decodable {
    var geonameId: Int
    var name: String
    var countryName: String
    var adminName1: String
    var lat: Double
    var lng: Double
    var countryCode: String
    var fcodeName: String
    var fclName: String
}

private struct PrivateSubstrate: Decodable {
    let _id: Int
    let name: String
    let name_uk: String
    let name_cz: String?
    let group_dk: String
    let group_uk: String
    let group_cz: String?
}

private struct PrivateVegetationType: Decodable {
    let _id: Int
    let name: String
    let name_uk: String
    let name_cz: String?
}

private struct PrivateGeom: Decodable {
    var coordinates: [Double]
}

private struct PrivateDeterminationView: Decodable {
    public private(set) var taxon_id: Int
    public private(set) var taxon_FullName: String
    public private(set) var taxon_vernacularname_dk: String?
    public private(set) var redlistStatus: String?
    public private(set) var determination_validation: String?
    public private(set) var determination_score: Int?
    let confidence: String?
}

private struct PrivatePrimaryDeterminationView: Decodable {
    public private(set) var score: Int?
    public private(set) var validation: String?
    public private(set) var Taxon: PrivateTaxon
    let confidence: String?
    
}

private struct PrivateAssociatedTaxa: Decodable {
    let _id: Int
    let DKname: String?
    let LatinName: String
}
private struct PrivateTaxon: Decodable {
    public private(set) var acceptedTaxon: AcceptedTaxon
}

private struct PrivateImages: Decodable {
    var _id: Int
    var name: String
    var createdAt: String
    var url: String {
        get {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "svampe.databasen.org"
            urlComponents.path = "/uploads/\(name).JPG"
            return urlComponents.url?.absoluteString ?? ""
        }
    }
}

private struct PrivatePrimaryUser: Decodable {
    var profile: PrivateProfile?
}

private struct PrivateProfile: Decodable {
    var name: String?
    var Initialer: String?
    var facebook: String?
}

private struct PrivateLocality: Decodable {
    var _id: Int
    var name: String?
    var kommune: String?
    let decimalLatitude: Double?
    let decimalLongitude: Double?
}

private struct PrivateForum: Decodable {
    var _id: Int?
    var createdAt: String?
    var content: String?
    var User: PrivateProfile?
}

private struct PrivateGeoName: Decodable {
    var geonameId: Int
    var name: String
    var countryName: String
    let lat: Double
    let lng: Double
}

// Front

struct Observation: Decodable, Equatable {
    enum ValidationStatus {
        case approved
        case verifying
        case rejected
        case unknown
    }
    
    public private(set) var id: Int
    let createdAt: String
    public private(set) var coordinates: [Double]
    public private(set) var location: CLLocation
    public private(set) var determination: Determination
    public private(set) var observationDate: String?
    public private(set) var observedBy: String?
    public private(set) var note: String?
    public private(set) var ecologyNote: String?
    public private(set) var locality: Locality?
    public private(set) var images: [Image]?
    public private(set) var comments = [Comment]()
    public private(set) var validationStatus: ValidationStatus
    public private(set) var substrate: Substrate?
    public private(set) var vegetationType: VegetationType?
    public private(set) var hosts: [Host]
    
    init(from decoder: Decoder) throws {
        let privateObservation = try PrivateObservation(from: decoder)

        id = privateObservation.id
        coordinates = privateObservation.geom.coordinates
        createdAt = privateObservation.createdAt
        
        if let latitude = privateObservation.geom.coordinates.last, let longitude = privateObservation.geom.coordinates.first {
            location = CLLocation.init(coordinate: .init(latitude: latitude, longitude: longitude), altitude: -1, horizontalAccuracy: Double(privateObservation.accuracy ?? -1), verticalAccuracy: -1.0, timestamp: Date())
        } else {
            location = CLLocation.init(latitude: 0, longitude: 0)
        }
        
        observationDate = privateObservation.observationDate
        observedBy = privateObservation.primaryUser?.profile?.name
        note = privateObservation.note
        ecologyNote = privateObservation.ecologyNote
        hosts = privateObservation.associatedTaxa?.map({Host.init(id: $0._id, dkName: $0.DKname, latinName: $0.LatinName, probability: 0, userFound: false)}) ?? []
        
        if let determinationScore =  privateObservation.determinationView?.determination_score, determinationScore >= 80 {
            validationStatus = .approved
        } else if let validation = privateObservation.determinationView?.determination_validation {
            switch validation {
            case "Afvist":
                validationStatus = .rejected
            case "Godkendt":
                validationStatus = .approved
            case "Valideres":
                validationStatus = .verifying
            default: validationStatus = .unknown
            }
        } else if let determinationScore = privateObservation.primaryDetermination?.score, determinationScore >= 80 {
            validationStatus = .approved
        } else if let validation = privateObservation.primaryDetermination?.validation {
            switch validation {
            case "Afvist":
                validationStatus = .rejected
            case "Godkendt":
                validationStatus = .approved
            case "Valideres":
                validationStatus = .verifying
            default: validationStatus = .unknown
            }
        } else {
            validationStatus = .unknown
        }
        
        if let geomNames = privateObservation.geoNames {
            locality = Locality(id: geomNames.geonameId, name: geomNames.name, latitude: geomNames.lat, longitude: geomNames.lng, geoName: GeoName(geonameId: geomNames.geonameId, name: geomNames.name, countryName: geomNames.countryName, adminName1: geomNames.adminName1, lat: String(geomNames.lat), lng: String(geomNames.lng), countryCode: geomNames.countryCode, fcodeName: geomNames.countryName, fclName: geomNames.fclName))
        } else if let locality = privateObservation.locality, let latitude = locality.decimalLatitude, let longitude = locality.decimalLongitude {
            self.locality = Locality(id: locality._id, name: locality.name ?? "", latitude: latitude, longitude: longitude, geoName: nil)
        }
        
        if let vegetationType = privateObservation.VegetationType {
            self.vegetationType = VegetationType(id: vegetationType._id, dkName: vegetationType.name, enName: vegetationType.name_uk, czName: vegetationType.name_cz)
        } else if let vegetationTypeID = privateObservation.vegetationtype_id {
            vegetationType = CoreDataHelper.fetchVegetationType(withID: vegetationTypeID)
        }
        
        if let substrate = privateObservation.Substrate {
            self.substrate = Substrate(id: substrate._id, dkName: substrate.name, enName: substrate.name_uk, czName: substrate.name_uk)
        } else if let substrateID = privateObservation.substrate_id {
            substrate = CoreDataHelper.fetchSubstrateGroup(withID: substrateID)
        }
        
        if let determinationView = privateObservation.determinationView {
            determination = Determination(id: determinationView.taxon_id, fullName: determinationView.taxon_FullName, danishName: determinationView.taxon_vernacularname_dk, confidence: determinationView.confidence)
        } else if let primaryDeterminationView = privateObservation.primaryDetermination {
            determination = Determination(id: primaryDeterminationView.Taxon.acceptedTaxon.id, fullName: primaryDeterminationView.Taxon.acceptedTaxon.fullName, danishName: primaryDeterminationView.Taxon.acceptedTaxon.vernacularNameDK?.vernacularname_dk, confidence: primaryDeterminationView.confidence)
        } else {
            throw DecodingError.dataCorruptedError(in: try decoder.unkeyedContainer(), debugDescription: "")
        }
        
        if let privateObservationImages = privateObservation.images {
            for privateImage in privateObservationImages {
                if images == nil {
                    images = [Image]()
                }
                images?.append(Image(id: privateImage._id, thumbURL: nil, url: privateImage.url, photographer: observedBy, createdDate: privateImage.createdAt))
            }
        }
        
        if let privateForums = privateObservation.forum {
            for privateForum in privateForums {
                guard let id = privateForum._id, let createdAt = privateForum.createdAt, let content = privateForum.content, let commenterName = privateForum.User?.name else {continue}
                comments.append(Comment(id: id, date: createdAt, content: content, commenterName: commenterName, initials: privateForum.User?.Initialer, commenterFacebookID: privateForum.User?.facebook))
            }
        }
    }
    
    func isDeleteable(user: User) -> Bool {
        guard user.isValidator == false else {return true}
        guard user.name == observedBy else {return false}
        guard let date = Date(ISO8601String: createdAt), let days = NSCalendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: date, to: Date()).day else {return false}
        return days > 2 ? false: true
    }
    
    func isEditable(user: User) -> Bool {
        guard user.isValidator == false else {return true}
        return user.name == observedBy ? true: false
    }
}

struct Determination: Decodable {
    public private(set) var id: Int
    public private(set) var fullName: String
    public private(set) var danishName: String?
    public private(set) var confidence: String?
    
    var name: String {
        switch Utilities.appLanguage() {
        case .danish:
            return danishName?.capitalizeFirst() ?? fullName.capitalizeFirst()
        default:
            return fullName.capitalizeFirst()
        }
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
