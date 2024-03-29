//
//  Constants.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import MapKit
import UIKit

struct Utilities {
    enum ApplicationLanguage {
        case danish
        case english
        case czech
    }
    
    static let PHOTOALBUMNAME = NSLocalizedString("utilities_photoAlbumName", comment: "")

    static func appLanguage() -> ApplicationLanguage {
        if Locale.current.identifier.contains("da") {
            return .danish
        } else if Locale.current.identifier.contains("en") {
            return .english
        } else if Locale.current.identifier.contains("cs") {
            return .czech
        } else {
            return .english
        }
    }

}

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
            return string
        }
    }
    
    enum Request {
        case Observations(geometry: Geometry, ageInYear: Int?, include: [ObservationIncludeQueries], limit: Int?, offset: Int?)
        case Observation(id: Int, include: [ObservationIncludeQueries])
        case Comments(observationID: Int)
        case Mushrooms(searchString: String?, speciesQueries: [SpeciesQueries], limit: Int?, offset: Int)
        case Mushroom(id: Int)
        case Hosts(searchString: String?)
        
        var encodedURL: String {
            
            switch self {
            case .Comments(observationID: let id):
                return BASE_URL_API + ""
            case .Observation(id: let id):
                return BASE_URL_API + "observations/\(id)"
            case .Observations(geometry: let geometry, let ageInYear, include: let include, let limit, let offset):
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
                
                return url
                
            case .Mushrooms(searchString: let searchString, var speciesQueries, let limit, let offset):
                var url = URLComponents()
                url.scheme = "https"
                url.host = "svampe.databasen.org"
                url.path = "/api/taxa"
                
                var queryItems = [URLQueryItem]()
                
                if let searchString = searchString {
                    queryItems.append(URLQueryItem(name: "where", value: createSearchQuery(searchString: searchString)))
                    queryItems.append(URLQueryItem(name: "order", value: "RankID ASC, probability DESC, FullName ASC"))
                    queryItems.append(URLQueryItem(name: "nocount", value: "true"))
                } else {
                    if let limit = limit {
                        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
                    }
                   
                    queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
                    queryItems.append(URLQueryItem(name: "order", value: "FullName ASC"))
                }
                
                queryItems.append(URLQueryItem(name: "include", value: parseSpeciesQueries(queries: speciesQueries)))
                url.queryItems = queryItems
                print(url.url!.absoluteString)
                return url.url!.absoluteString
                
            case .Mushroom(id: let id):
                var url = URLComponents()
                url.scheme = "https"
                url.host = "svampe.databasen.org"
                url.path = "/api/taxa"
                
                let limitQuery = URLQueryItem(name: "include", value: parseSpeciesQueries(queries: [SpeciesQueries.attributes(presentInDenmark: nil), SpeciesQueries.danishNames, SpeciesQueries.images(required: false), SpeciesQueries.redlistData, SpeciesQueries.statistics]))
                let whereQuery = URLQueryItem(name: "where", value: "{\"_id\":\(id)}")
                url.queryItems = [limitQuery, whereQuery]
                //                debugPrint(url.url!.absoluteString)
                return url.url!.absoluteString
            case .Hosts(searchString: let searchString):
                
                var url = BASE_URL_API + "planttaxa?limit=30&order=probability+DESC"
                
                if let searchString = searchString, searchString != "" {
                    url.append("""
                        &where={"$or":[{"DKname":{"like":"\(searchString)%"}},{"LatinName":{"like":"\(searchString)%"}}]}
                        """.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    
                }
                return url
            default:
                return ""
            }
        }
    }
    
    enum Post {
        case comment(taxonID: Int)
        case offensiveContentComment(taxonID: Int)
        case imagePredict(speciesQueries: [SpeciesQueries])
        
        var encodedURL: String {
            switch self {
            case .comment(taxonID: let taxonID):
                return BASE_URL_API + "observations/\(taxonID)/forum"
            case .offensiveContentComment(taxonID: let taxonID):
                return BASE_URL_API + "observations/\(taxonID)/notifications"
            case .imagePredict(speciesQueries: let speciesQueries):
                var url = URLComponents()
                url.scheme = "https"
                url.host = "svampe.databasen.org"
                url.path = "/api/imagevision"
                url.queryItems = [URLQueryItem(name: "include", value: parseSpeciesQueries(queries: speciesQueries))]
                print(url.url!.absoluteString)
                return url.url!.absoluteString
            default:
                return ""
            }
        }
    }
    
    enum Put {
        case observation(id: Int)
        case notificationLastRead(notificationID: Int)
        
        var encodedURL: String {
            switch self {
            case .observation(id: let id):
                return BASE_URL_API + "observations/\(id)"
            case .notificationLastRead(let notificationID):
                let url = BASE_URL_API + "users/me/feed/\(notificationID)/lastread"
                //                debugPrint(url)
                return BASE_URL_API + "users/me/feed/\(notificationID)/lastread"
            }
        }
    }
    
    enum Delete {
        case image(id: Int)
        case observation(id: Int)
        
        var encodedURL: String {
            switch self {
            case .image(id: let id):
                return BASE_URL_API + "observationimages/\(id)"
            case .observation(id: let id):
                return BASE_URL_API + "observations/\(id)"
            }
        }
    }
    
    enum SpeciesQueries {
        case attributes(presentInDenmark: Bool?)
        case images(required: Bool)
        case danishNames
        case statistics
        case redlistData
        case acceptedTaxon
        case tag(id: Int)
        
        var query: String {
            switch self {
            case .attributes(presentInDenmark: let presentInDenmark):
                var baseQuery = "{\"model\":\"TaxonAttributes\",\"as\":\"attributes\",\"attributes\":[\"valideringsrapport\",\"PresentInDK\", \"diagnose\", \"beskrivelse\", \"forvekslingsmuligheder\", \"oekologi\", \"bogtekst_gyldendal_en\", \"bogtekst_gyldendal\", \"spiselighedsrapport\", \"vernacular_name_CZ\", \"vernacular_name_GB\"]"
                
                if let presentInDenmark = presentInDenmark {
                    baseQuery += ",\"where\":\"{\\\"PresentInDK\\\":\(presentInDenmark)}\""
                }
                
                return baseQuery + "}"
            case .danishNames:
                return "{\"model\":\"TaxonDKnames\",\"as\":\"Vernacularname_DK\", \"attributes\":[\"vernacularname_dk\", \"source\"]}"
                
            case .images(required: let required):
                return "{\"model\":\"TaxonImages\",\"as\":\"Images\",\"required\":\(required)}"
            case .redlistData:
                return "{\"model\":\"TaxonRedListData\",\"as\":\"redlistdata\",\"required\":false,\"attributes\":[\"status\"],\"where\":\"{\\\"year\\\":2019}\"}"
            case .statistics:
                return "{\"model\":\"TaxonStatistics\",\"as\":\"Statistics\", \"attributes\":[\"accepted_count\", \"last_accepted_record\", \"first_accepted_record\"]}"
            case .tag(id: let id):
                return "{\"model\":\"TaxonomyTagView\",\"as\":\"tags0\",\"where\":\"{\\\"tag_id\\\":\(id)}\"}"
                
            case .acceptedTaxon:
                return "{\"model\":\"Taxon\",\"as\":\"acceptedTaxon\"}"
                
            }
        }
    }
    
    enum ObservationIncludeQueries {
        case images
        case comments
        case determinationView(taxonID: Int?)
        case user(responseFilteredByUserID: Int?)
        case locality
        case geomNames
        
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
                return "%7B%5C%22model%5C%22%3A%5C%22Locality%5C%22%2C%5C%22as%5C%22%3A%5C%22Locality%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22_id%5C%22%2C%5C%22name%5C%22%2C%5C%22decimalLatitude%5C%22%2C%5C%22decimalLongitude%5C%22%5D%7D"
                
            case .geomNames:
                return "%7B%5C%22model%5C%22%3A%5C%22GeoNames%5C%22%2C%5C%22as%5C%22%3A%5C%22GeoNames%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D"
            }
        }
        
    }
    
    private static func parseSpeciesQueries(queries: [SpeciesQueries]) -> String {
        var string = "["
        
        for query in queries {
            string.append(query.query)
            string.append(",")
        }
        
        if !queries.isEmpty { _ = string.popLast() }
        string.append("]")
        return string
    }
    
    private static func createSearchQuery(searchString: String) -> String {
        let speciesSearchResult = SearchStringParser.parseSpeciesSearch(searchString: searchString)
        switch Utilities.appLanguage() {
        case .czech:
            return "{\"RankID\":{\"gt\":4999},\"$or\":[{\"FullName\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"$attributes.vernacular_name_CZ$\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"FullName\":{\"like\":\"\(speciesSearchResult.genus)%\"},\"TaxonName\":{\"like\":\"\(speciesSearchResult.taxonName)%\"}}]}"
        case .danish:
            return "{\"RankID\":{\"gt\":4999},\"$or\":[{\"FullName\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"$Vernacularname_DK.vernacularname_dk$\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"FullName\":{\"like\":\"\(speciesSearchResult.genus)%\"},\"TaxonName\":{\"like\":\"\(speciesSearchResult.taxonName)%\"}}]}"
        case .english:
            return "{\"RankID\":{\"gt\":4999},\"$or\":[{\"FullName\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"$attributes.vernacular_name_GB$\":{\"like\":\"%\(speciesSearchResult.fullSearch)%\"}},{\"FullName\":{\"like\":\"\(speciesSearchResult.genus)%\"},\"TaxonName\":{\"like\":\"\(speciesSearchResult.taxonName)%\"}}]}"
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
        let url = BASE_URL_API + "users/me/feed?limit=\(limit)?offset=\(offset)"
        //        debugPrint(url)
        return url
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
        //        print(url)
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
        case country = 0
    }
    
    static func localitiesURL(coordinates: CLLocationCoordinate2D, radius: Radius) -> String {
        let coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        if radius != Radius.country {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius.rawValue, longitudinalMeters: radius.rawValue)
            
            let cord1 = CLLocationCoordinate2D(latitude: coordinate.latitude + region.span.latitudeDelta, longitude: coordinate.longitude + region.span.longitudeDelta)
            let cord2 = CLLocationCoordinate2D(latitude: coordinate.latitude - region.span.latitudeDelta, longitude: coordinate.longitude - region.span.longitudeDelta)
            
            let result = BASE_URL_API + "localities?where=%7B%22decimalLongitude%22:%7B%22$between%22:%5B\(cord2.longitude),\(cord1.longitude)%5D%7D,%22decimalLatitude%22:%7B%22$between%22:%5B\(cord2.latitude),\(cord1.latitude)%5D%7D%7D"
            
            return result
        } else {
            let url = BASE_URL_API + "geonames/findnearby?lat=\(coordinates.latitude)&lng=\(coordinates.longitude)"
            //            print(url)
            return url
        }
        
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
private let BASE_URL_API = "https://" + BASE_URL + "/api/"

let ME_URL = BASE_URL_API + "users/me"
let LOGIN_URL = "https://" + BASE_URL + "/auth/local"

func SPECIES_INCLUDE_QUERY(imagesRequired: Bool) -> String {
    return "&include=%5B%7B%22model%22%3A%22TaxonRedListData%22%2C%22as%22%3A%22redlistdata%22%2C%22required%22%3Afalse%2C%22attributes%22%3A%5B%22status%22%5D%2C%22where%22%3A%22%7B%5C%22year%5C%22%3A2009%7D%22%7D%2C%7B%22model%22%3A%22Taxon%22%2C%22as%22%3A%22acceptedTaxon%22%7D%2C%7B%22model%22%3A%22TaxonAttributes%22%2C%22as%22%3A%22attributes%22%2C%22attributes%22%3A%5B%22PresentInDK%22%2C%20%22forvekslingsmuligheder%22%2C%20%22oekologi%22%2C%20%22diagnose%22%5D%2C%22where%22%3A%22%7B%5C%22PresentInDK%5C%22%3Atrue%7D%22%7D%2C%7B%22model%22%3A%22TaxonDKnames%22%2C%22as%22%3A%22Vernacularname_DK%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonStatistics%22%2C%22as%22%3A%22Statistics%22%2C%22required%22%3Afalse%7D%2C%7B%22model%22%3A%22TaxonImages%22%2C%22as%22%3A%22images%22%2C%22required%22%3A\(imagesRequired)%7D%5D"
}

func ALLMUSHROOMS_URL(limit: Int, offset: Int) -> String {
    let string = BASE_URL_API + "taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true" + SPECIES_INCLUDE_QUERY(imagesRequired: true) + "&limit=\(limit)" + "&offset=\(offset)"
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
    //    print(returned)
    return returned
}

private let SPECIES_LIST_BASE_URL = "svampe.databasen.org/api/observations/specieslist"
