//
//  Constants.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class NewObservation {
    
    enum Error {
        case noMushroom
        case noSubstrateGroup
        case noVegetationType
        case noLocality
    }
    
    var observationDate: Date
    var observationDateAccuracy = "day"
    var substrate: Substrate?
    var vegetationType: VegetationType?
    var hosts = [Host]()
    var lockedHosts = false
    var ecologyNote: String?
    var mushroom: Mushroom?
    var confidence: String = "sikker"
    var note: String?
    var observationCoordinate: CLLocation?
    var user: User?
    var locality: Locality?
    var images = [UIImage]()
    
    
    init() {
        self.observationDate = Date()
        
        if let substrateID = UserDefaultsHelper.defaultSubstrateID {
            self.substrate = CoreDataHelper.fetchSubstrateGroup(withID: substrateID)
            self.substrate?.isLocked = true
        }
        
        if let vegetationTypeID = UserDefaultsHelper.defaultVegetationTypeID {
            self.vegetationType = CoreDataHelper.fetchVegetationType(withID: vegetationTypeID)
            self.vegetationType?.isLocked = true
        }
        
        if let hostsIDS = UserDefaultsHelper.defaultHostsIDS {
            self.hosts = hostsIDS.compactMap({CoreDataHelper.fetchHost(withID: $0)})
            self.lockedHosts = true
        }
    }
    
    func isComplete() -> Result<Bool, Error> {
        if mushroom == nil {
            guard images.count != 0  else {return Result.Error(Error.noMushroom)}
        }
        
        guard substrate != nil else {return Result.Error(Error.noSubstrateGroup)}
        guard vegetationType != nil else {return Result.Error(Error.noVegetationType)}
        guard locality != nil else {return Result.Error(Error.noLocality)}
        return Result.Success(true)
    }
    
    func returnAsDictionary() -> [String: Any] {
        var dict: [String: Any] = ["observationDate": observationDate.convert(into: "yyyy-MM-dd")]
        
        dict["os"] = "iOS"
        dict["browser"] = "Native App"
        
        if let substrate = substrate {
             dict["substrate_id"] = substrate.id
        }
        
        if let vegetationType = vegetationType {
            dict["vegetationtype_id"] = vegetationType.id
        }
        
        if let ecologyNote = ecologyNote {
            dict["ecologynote"] = ecologyNote
        }
        
        if let note = note {
            dict["note"] = note
        }
        
        if let observationCoordinate = observationCoordinate {
            dict["decimalLatitude"] = observationCoordinate.coordinate.latitude
            dict["decimalLongitude"] = observationCoordinate.coordinate.longitude
            dict["accuracy"] = observationCoordinate.horizontalAccuracy
        }
        
        if hosts.count > 0 {
            var hostArray = [[String: Any]]()
            
            for host in hosts {
                hostArray.append(["_id": host.id])
            }
            
            dict["associatedOrganisms"] = hostArray
        }
        
        if let user = user {
            dict["users"] = [["_id": user.id, "Initialer": user.initials, "email": user.email, "facebook": user.facebookID ?? "", "name": user.name]]
        }
        
        if let mushroom = mushroom, let user = user {
            dict["determination"] = ["confidence": confidence, "taxon_id": mushroom.id, "user_id": user.id]
        } else {
            dict["determination"] = ["confidence": "sikker", "taxon_id": "60212", "user_id": user!.id]
        }
        
        if let locality = locality {
            dict["locality_id"] = locality.id
        }
       return dict
    }
}

/*
 
 https://svampe.databasen.org/api/observations/9358023/images
 [{
 "createdAt": "2019-01-09T16:26:04.000Z",
 "_id": 163758,
 "eventname": "Added image",
 "description": "2019-9358023_BJ4oljQGN was added to this record.",
 "user_id": 5,
 "observation_id": 9358023,
 "updatedAt": "2019-01-09T16:26:04.000Z"
 }]
 

 
 
 {
 "createdAt": "2019-01-09T10:11:58.000Z",
 "observationDateAccuracy": "day",
 "atlasUUID": "ffdb8590-13f6-11e9-b3ce-695d96b95c60",
 "_id": 9357979,
 "observationDate": "2019-01-09",
 "substrate_id": "28",
 "vegetationtype_id": "3",
 "ecologynote": "Test",
 "accuracy": 2500,
 "note": "Test",
 "os": "MacOS",
 "browser": "Safari",
 "locality_id": 10445,
 "decimalLatitude": 55.65125,
 "decimalLongitude": 12.57708,
 "primaryuser_id": 5,
 "geom": {
 "fn": "GeomFromText",
 "args": [
 "POINT (12.57708 55.65125)"
 ]
 },
 "updatedAt": "2019-01-09T10:11:58.000Z",
 "primarydetermination_id": 5744369
 }
 
 
{
    "createdAt": "2019-01-09T10:11:58.000Z",
    "observationDateAccuracy": "day",
    "atlasUUID": "ffdb8590-13f6-11e9-b3ce-695d96b95c60",
    "_id": 9357979,
    "observationDate": "2019-01-09",
    "substrate_id": "28",
    "vegetationtype_id": "3",
    "ecologynote": "Test",
    "accuracy": 2500,
    "note": "Test",
    "os": "MacOS",
    "browser": "Safari",
    "locality_id": 10445,
    "decimalLatitude": 55.65125,
    "decimalLongitude": 12.57708,
    "primaryuser_id": 5,
    "geom": {
        "fn": "GeomFromText",
        "args": [
        "POINT (12.57708 55.65125)"
        ]
    },
    "updatedAt": "2019-01-09T10:11:58.000Z",
    "primarydetermination_id": 5744369
}*/

/*
 
 {"observationDate":"2019-05-23","substrate_id":"28","vegetationtype_id":"5","accuracy":1000,"associatedOrganisms":[{"_id":1022,"createdAt":"2016-03-07T08:49:51.000Z","updatedAt":null,"DKname":"bøg","DKandLatinName":"bøg (Fagus)","Ectomycorrhizal":"0","Genus":1,"LatinName":"Fagus","LatinCode":"Fag","WoodySubstrate":"x","parent_id":null,"accepted_id":1022,"gbiftaxon_id":2874875,"defaultlist":true,"probability":110130}],"associatedOrganismImport":[],"users":[{"_id":2706,"Initialer":"emill","email":"emillind@me.com","provider":"local","name":"Emil Lind","Roles":[],"facebook":"161977228083409","preferred_language":"da"}],"os":"MacOS","browser":"Safari","determination":{"taxon_id":13003,"user_id":2706,"confidence":"sikker"},"locality_id":160,"decimalLatitude":55.10901525530758,"decimalLongitude":14.759445190429686,"primaryassociatedorganism_id":1022}
 
 
 POST FUND: https://svampe.databasen.org/api/observations
 
 "createdAt": "2018-12-06T20:49:29.000Z",
 "observationDateAccuracy": "day",
 "atlasUUID": "6d0e2970-f998-11e8-9609-e76ff0de5fb8",
 "_id": 9353834,
 "observationDate": "2018-12-06",
 "substrate_id": "29",
 "vegetationtype_id": "10",
 "ecologynote": "Økologi test",
 "accuracy": 2500,
 "os": "MacOS",
 "browser": "Safari",
 "locality_id": 10465,
 "decimalLatitude": 55.67372,
 "decimalLongitude": 12.56844,
 "primaryuser_id": 5,
 "geom": {
 "fn": "GeomFromText",
 "args": [
 "POINT (12.56844 55.67372)"
 ]
 },
 "updatedAt": "2018-12-06T20:49:29.000Z",
 "primarydetermination_id": 5739287
 }
 
 
 */


struct API {
    
    struct Geometry {
        enum ´Type´ {
            case circle
            case rectangle
        }
        
        public private(set) var coordinate: CLLocationCoordinate2D
        public private(set) var radius: CLLocationDistance
        public private(set) var type: ´Type´ = .circle
        
        func geoJSON() -> String {
            var string = "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[["
            
            switch type {
            case .circle:
                for coordinate in coordinate.toCirclePolygon(radius: radius) {
                    string.append("[\(coordinate.longitude),\(coordinate.latitude)],")
                }
            case .rectangle:
                for coordinate in coordinate.toRectanglePolygon(radius: radius) {
                    string.append("[\(coordinate.longitude),\(coordinate.latitude)],")
                }
            }
            
            _ = string.popLast()
            string.append("]]}}")
            print(string)
            return string
        }
    }
    
    enum Request {
        case Observation(geometry: Geometry, ageInYear: Int?, include: [ObservationIncludeQueries], limit: Int?, offset: Int?)
        case Mushroom(searchString: String?, requirePictures: Bool)
        
        var encodedURL: String {
            switch self {
            case .Observation(geometry: let geometry, let ageInYear, include: let include, let limit, let offset):
                var components = URLComponents()
                let geometry = URLQueryItem(name: "geometry", value: geometry.geoJSON())
                components.queryItems = [geometry]
            
                if let ageInYear = ageInYear, let dateString = Date(age: ageInYear * 12)?.convert(into: "yyyy-MM-dd") {
                    components.queryItems?.append(URLQueryItem(name: "where", value: "{\"observationDate\":{\"$gte\":\"\(dateString)\"}}"))
                }
                
                var url: String = BASE_URL_API + "observations?" + ((components.percentEncodedQuery) ?? "") + includeQuery(includeQueries: include)
            
                
                if let limit = limit {
                    url += "&limit=\(limit)"
                }
                
                if let offset = offset {
                    url += "&offset=\(offset)"
                }
                
               print(url)
               return url
            case .Mushroom(searchString: let searchString, requirePictures: let requirePictures):
                return ""
            default:
                return ""
            }
        }
    }
    
    enum Post {
        case comment(taxonID: Int)
        case offensiveContentComment(taxonID: Int)
        
        var encodedURL: String {
            switch self {
            case .comment(taxonID: let taxonID):
                return BASE_URL_API + "observations/\(taxonID)/forum"
            case .offensiveContentComment(taxonID: let taxonID):
                return BASE_URL_API + "observations/\(taxonID)/notifications"
            default:
                return ""
            }
        }
    }
    
    
    enum ObservationIncludeQueries {
        case images
        case comments
        case determinationView(taxonID: Int?)
        case user(responseFilteredByUserID: Int?)
        case locality
        
        var encodedQuery: String {
            switch self {
                
            case .determinationView(taxonID: let taxonID):
                if let taxonID = taxonID {
                    return "%7B%5C%22model%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22as%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22taxon_id%5C%22%2C%5C%22recorded_as_id%5C%22%2C%5C%22taxon_FullName%5C%22%2C%5C%22taxon_vernacularname_dk%5C%22%2C%5C%22determination_validation%5C%22%2C%5C%22recorded_as_FullName%5C%22%2C%5C%22determination_user_id%5C%22%2C%5C%22determination_score%5C%22%2C%5C%22determination_validator_id%5C%22%2C%5C%22determination_species_hypothesis%5C%22%5D%2C%5C%22where%5C%22%3A%7B%5C%22Taxon_id%5C%22%3A\(taxonID)%7D%7D"
                } else {
                    return "%7B%5C%22model%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22as%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22taxon_id%5C%22%2C%5C%22recorded_as_id%5C%22%2C%5C%22taxon_FullName%5C%22%2C%5C%22taxon_vernacularname_dk%5C%22%2C%5C%22determination_validation%5C%22%2C%5C%22recorded_as_FullName%5C%22%2C%5C%22determination_user_id%5C%22%2C%5C%22determination_score%5C%22%2C%5C%22determination_validator_id%5C%22%2C%5C%22determination_species_hypothesis%5C%22%5D%7D"
                }
                
                
            case .images:
                return "%7B%5C%22model%5C%22%3A%5C%22ObservationImage%5C%22%2C%5C%22as%5C%22%3A%5C%22Images%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D"
            case .comments: return "%7B%5C%22model%5C%22%3A%5C%22ObservationForum%5C%22%2C%5C%22as%5C%22%3A%5C%22Forum%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D"
            case .user(responseFilteredByUserID: let id):
                if let id = id {
                     return "%7B%5C%22model%5C%22%3A%5C%22User%5C%22%2C%5C%22as%5C%22%3A%5C%22PrimaryUser%5C%22%2C%5C%22required%5C%22%3Atrue%2C%5C%22where%5C%22%3A%7B%5C%22_id%5C%22%3A\(id)%7D%7D"
                } else {
                    return "%7B%5C%22model%5C%22%3A%5C%22User%5C%22%2C%5C%22as%5C%22%3A%5C%22PrimaryUser%5C%22%2C%5C%22required%5C%22%3Atrue%7D"
                }
               
            case .locality:
                return "%7B%5C%22model%5C%22%3A%5C%22Locality%5C%22%2C%5C%22as%5C%22%3A%5C%22Locality%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22_id%5C%22%2C%5C%22name%5C%22%5D%7D"
            }
        }
        
    }
    
    private static func parseQueryEnums(observationIncludeQueries: [ObservationIncludeQueries]) -> String {
        var string = ""
        for i in 0..<observationIncludeQueries.count {
            string.append(observationIncludeQueries[i].encodedQuery)
            
            if i != observationIncludeQueries.endIndex - 1 {
                string.append("%22%2C%22")
            } else {
                string.append("%22%5D")
            }
        }
        return string
    }
    
    static func userNotificationsURL(userID id: Int, limit: Int, offset: Int) -> String {
        return BASE_URL_API + "users/me/feed?limit=\(limit)?offset=\(offset)"
    }
    
    static func observationWithIDURL(observationID id: Int) -> String {
        return BASE_URL_API + "observations/\(id)"
    }
    
    static func userNotificationsCountURL() -> String {
        return BASE_URL_API + "users/me/feed/count"
    }
    
    static func userObservationsCountURL(userID id: Int) -> String {
        return BASE_URL_API + "users/\(id)/observations/count"
    }
    
    static func observationsURL(includeQueries: [ObservationIncludeQueries], limit: Int, offset: Int) -> String {
        let url = BASE_URL_API + "observations?_order=%5B%5B%22observationDate%22,%22DESC%22,%22ASC%22%5D,%5B%22_id%22,%22DESC%22%5D%5D" + includeQuery(includeQueries: includeQueries) + "&limit=\(limit)&offset=\(offset)&where=%7B%7D"
        print(url)
        return url
    }
    
    static func includeQuery(includeQueries: [ObservationIncludeQueries]) -> String {
        return "&include=%5B%22" + parseQueryEnums(observationIncludeQueries: includeQueries)
    }
    
    static func substrateURL() -> String {
        return BASE_URL_API + "substrate"
    }
    
    static func vegetationTypeURL() -> String {
        return BASE_URL_API + "vegetationtypes"
    }
    
    static func hostsURL() -> String {
        return BASE_URL_API + "planttaxa?limit=30&order=probability+DESC"
    }
    
    static func postObservationURL() -> String {
        return BASE_URL_API + "observations"
    }
    
    enum Radius: CLLocationDistance {
        case smallest = 800
        case smaller = 1000
        case small = 1200
        case medium = 1400
        case large = 1600
        case larger = 1800
        case largest = 2000
        case huge = 2500
        case huger = 5000
        case hugest = 10000
    }
    
    
    static func localitiesURL(coordinates: CLLocationCoordinate2D, radius: Radius) -> String {
        let coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius.rawValue, longitudinalMeters: radius.rawValue)
        
        let cord1 = CLLocationCoordinate2D(latitude: coordinate.latitude + region.span.latitudeDelta, longitude: coordinate.longitude + region.span.longitudeDelta)
        let cord2 = CLLocationCoordinate2D(latitude: coordinate.latitude - region.span.latitudeDelta, longitude: coordinate.longitude - region.span.longitudeDelta)
    
            let result = BASE_URL_API + "localities?where=%7B%22decimalLongitude%22:%7B%22$between%22:%5B\(cord2.longitude),\(cord1.longitude)%5D%7D,%22decimalLatitude%22:%7B%22$between%22:%5B\(cord2.latitude),\(cord1.latitude)%5D%7D%7D"
        print(result)
        return result
    }
    
    static func postImageURL(observationID: Int) -> String {
        return BASE_URL_API + "observations/\(observationID)/images"
    }
    
    static func userURL() -> String {
        return BASE_URL_API + "users/me"
    }
    
    static func mushroom(withID id: Int) -> String {
        return BASE_URL_API + "taxa?" + SPECIES_INCLUDE_QUERY(imagesRequired: false) + "&where=%7B%22_id%22%3A\(id)%7D"
    }
}



let BASE_URL = "svampe.databasen.org"
fileprivate let BASE_URL_API = "https://" + BASE_URL + "/api/"

let ME_URL = BASE_URL_API + "users/me"
let LOGIN_URL = "https://" + BASE_URL + "/auth/local"

func SPECIES_INCLUDE_QUERY(imagesRequired: Bool) -> String {
    return "&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22images%22%2C%22required%22%3A\(imagesRequired)%7D%5D"
}

func ALLMUSHROOMS_URL(limit: Int, offset: Int) -> String {
    let string = BASE_URL_API + "taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true" + SPECIES_INCLUDE_QUERY(imagesRequired: true) + "&limit=\(limit)" + "&offset=\(offset)"
    print(string)
    return string
}



func SEARCHFORMUSHROOM_URL(searchTerm: String) -> String {
    var genus = ""
    var fullSearchTerm = ""
    var taxonName = ""
    
    for word in searchTerm.components(separatedBy: " ") {
        guard word != "", let encodedWord = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) else {break}
        if fullSearchTerm == "" {
            fullSearchTerm = encodedWord
            genus = encodedWord
        } else {
            fullSearchTerm += "+\(encodedWord)"
            if taxonName == "" {
                taxonName = encodedWord
            } else {
                taxonName += "+\(encodedWord)"
            }
        }
    }
    
    
    let returned = BASE_URL_API + "taxa?" + "include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22images%22%2C%22required%22%3Afalse%7D%5D" + "&nocount=true&where=%7B%22%24or%22%3A%5B%7B%22FullName%22%3A%7B%22like%22%3A%22%25\(fullSearchTerm)%25%22%7D%7D%2C%7B%22%24Vernacularname_DK.vernacularname_dk%24%22%3A%7B%22like%22%3A%22%25\(fullSearchTerm)%25%22%7D%7D%2C%7B%22FullName%22%3A%7B%22like%22%3A%22\(genus)%25%22%7D%2C%22TaxonName%22%3A%7B%22like%22%3A%22\(taxonName)%25%22%7D%7D%5D%7D"
    print(returned)
    return returned
}


fileprivate let BASE_URL_OLD = "https://svampe.databasen.org/api/taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22Images%22%2C%22required%22%3Atrue%7D%5D&limit=100&offset=0"

//https://svampe.databasen.org/apitaxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22Images%22%2C%22required%22%3Atrue%7D%5D&limit=100&offset=0


fileprivate let SPECIES_LIST_BASE_URL = "svampe.databasen.org/api/observations/specieslist"


