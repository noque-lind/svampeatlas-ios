//
//  Mushroom.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 18/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import UIKit


fileprivate struct PrivateMushroom: Decodable {
    var _id: Int?
    var FullName: String?
    var Author: String?
    var updatedAt: String?
    var probability: Int?
    var Vernacularname_DK: PrivateVernacularNameDK?
    var redlistdata: [PrivateRedlistData]?
    var images: [PrivateImage]?
    var attributes: PrivateAttributes?
    var Statistics: PrivateStatistics?
}

fileprivate struct PrivateVernacularNameDK: Decodable {
    var vernacularname_dk: String?
    var source: String?
}

fileprivate struct PrivateRedlistData: Decodable {
    var status: String?
    var year: Int?
    var Udbredelse: String?
}

fileprivate struct PrivateImage: Decodable {
    var thumburi: String?
    var uri: String?
    var photographer: String?
}

fileprivate struct PrivateAttributes: Decodable {
    var diagnose: String?
    var forvekslingsmuligheder: String?
    var oekologi: String?
    var spiselighedsrapport: String?
}

fileprivate struct PrivateStatistics: Decodable {
    var total_count: Int?
    var last_accepted_record: String?
}

struct Mushroom: Decodable {
    public private(set) var id: Int
    public private(set) var fullName: String
    public private(set) var fullNameAuthor: String?
    public private(set) var updatedAt: String?
    public private(set) var danishName: String?
    public private(set) var totalObservations: Int?
    public private(set) var lastAcceptedObservation: String?
    public private(set) var redlistData: RedlistData?
    public private(set) var attributes: Attributes?
    public private(set) var images: [Image]?
    

    init(from decoder: Decoder) throws {
        let privateMushroom = try PrivateMushroom(from: decoder)
        id = privateMushroom._id ?? 0
        fullName = privateMushroom.FullName?.capitalizeFirst() ?? ""
        fullNameAuthor = privateMushroom.Author?.capitalizeFirst()
        updatedAt = privateMushroom.updatedAt
        danishName = privateMushroom.Vernacularname_DK?.vernacularname_dk?.capitalizeFirst()
        totalObservations = privateMushroom.Statistics?.total_count
        lastAcceptedObservation = privateMushroom.Statistics?.last_accepted_record
        
        if let privateRedlistData = privateMushroom.redlistdata?.first, let status = privateRedlistData.status {
            redlistData = RedlistData(status: status, year: privateRedlistData.year, spread: privateRedlistData.Udbredelse)
        }
        
        if let privateAttributes = privateMushroom.attributes {
            attributes = Attributes(ecology: privateAttributes.oekologi?.capitalizeFirst(), diagnosis: privateAttributes.diagnose?.capitalizeFirst(), similarities: privateAttributes.forvekslingsmuligheder?.capitalizeFirst())
        }
        
        if let privateImages = privateMushroom.images, privateImages.count != 0 {
            images = [Image]()
            for privateImage in privateImages {
                guard let url = privateImage.uri else {break}
                images?.append(Image(thumbURL: privateImage.thumburi, url: url, photographer: privateImage.photographer))
            }
        }
    }
    
    init(from cdMushroom: CDMushroom) {
        id = Int(cdMushroom.id)
        fullName = cdMushroom.fullName ?? "Uventet fejl"
        danishName = cdMushroom.danishName
        updatedAt = cdMushroom.updatedAt
        
        if let redlistStatus = cdMushroom.redlistStatus {
            redlistData = RedlistData(status: redlistStatus, year: nil, spread: nil)
        }
        
        
        if let attributes = cdMushroom.attributes {
            self.attributes = Attributes(ecology: attributes.ecology, diagnosis: attributes.diagnosis, similarities: nil)
        }
        
        if let cdImages = cdMushroom.images?.allObjects as? [CDImage], cdImages.count != 0 {
            images = [Image]()
            for cdImage in cdImages {
                guard let url = cdImage.url else {continue}
                images?.append(Image(thumbURL: nil, url: url, photographer: cdImage.photographer))
            }
        }
    }
}


struct Image: Decodable {
    public private(set) var thumbURL: String?
    public private(set) var url: String
    public private(set) var photographer: String?
}

struct RedlistData: Decodable {
    public private(set) var status: String
    public private(set) var year: Int?
    public private(set) var spread: String?
}

struct Attributes: Decodable {
    public private(set) var ecology: String?
    public private(set) var diagnosis: String?
//    public private(set) var toxicityLevel: ToxicityLevel? = ToxicityLevel.createRandom()
    public private(set) var similarities: String?
}

enum ToxicityLevel: String {
    case toxic = "GIFTIG"
    case eatable = "SPISELIG"
    case cautious = "VÆR FORSIGTIG"
    
    static func createRandom() -> ToxicityLevel {
       let random = arc4random_uniform(3)
        switch random {
        case 0:
            return ToxicityLevel.cautious
        case 1:
            return ToxicityLevel.eatable
        default:
            return ToxicityLevel.eatable
    
        }
    }
}





