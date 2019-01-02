//
//  Constants.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation


/*
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
    
    static func observationsURL(includeQueries: [ObservationIncludeQueries], limit: Int = 24, offset: Int = 0) -> String {
        return BASE_URL_API + "observations?_order=%5B%5B%22observationDate%22,%22DESC%22,%22ASC%22%5D,%5B%22_id%22,%22DESC%22%5D%5D" + includeQuery(includeQueries: includeQueries) + "&limit=\(limit)&offset=\(offset)&where=%7B%7D"
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
}



let BASE_URL = "svampe.databasen.org"
fileprivate let BASE_URL_API = "https://" + BASE_URL + "/api/"

let ME_URL = BASE_URL_API + "users/me"
let LOGIN_URL = "https://" + BASE_URL + "/auth/local"

func SPECIES_INCLUDE_QUERY(imagesRequired: Bool) -> String {
    return "&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22images%22%2C%22required%22%3A\(imagesRequired)%7D%5D"
}

func ALLMUSHROOMS_URL(limit: Int, offset: Int) -> String {
    return BASE_URL_API + "taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true" + SPECIES_INCLUDE_QUERY(imagesRequired: true) + "&limit=\(limit)" + "&offset=\(offset)"
}

func MUSHROOM_URL(taxonID: Int) -> String {
    return BASE_URL_API + "taxa?" + SPECIES_INCLUDE_QUERY(imagesRequired: false) + "&where=%7B%22_id%22%3A\(taxonID)%7D"
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
    
    
    let returned = BASE_URL_API + "taxa?" + SPECIES_INCLUDE_QUERY(imagesRequired: false) + "&nocount=true&where=%7B%22$or%22:%5B%7B%22FullName%22:%7B%22like%22:%22%25\(fullSearchTerm)%25%22%7D%7D,%7B%22$Vernacularname_DK.vernacularname_dk$%22:%7B%22like%22:%22%25\(fullSearchTerm)%25%22%7D%7D%5D%7D"
    print(returned)
    return returned
}


fileprivate let BASE_URL_OLD = "https://svampe.databasen.org/api/taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22Images%22%2C%22required%22%3Atrue%7D%5D&limit=100&offset=0"

//https://svampe.databasen.org/apitaxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22Images%22%2C%22required%22%3Atrue%7D%5D&limit=100&offset=0


fileprivate let SPECIES_LIST_BASE_URL = "svampe.databasen.org/api/observations/specieslist"


