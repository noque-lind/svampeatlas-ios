//
//  Mushroom.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 18/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
struct Mushroom: Decodable {
    public private(set) var id: Int?
    public private(set) var createdAt: String?
    public private(set) var updatedAt: String?
    public private(set) var path: String?
    public private(set) var systematicPath: String?
    public private(set) var fullName: String?
    public private(set) var funIndexCurrUseNumber: Int?
    public private(set) var funIndexTypificationNumber: Int?
    public private(set) var funIndexNumber: Int?
    public private(set) var rankID: Int?
    public private(set) var rankName: String?
    public private(set) var taxonName: String?
    public private(set) var author: String?
    public private(set) var vernacularName_dk_id: Int?
    public private(set) var morphogroup_id: Int?
    public private(set) var parent_id: Int?
    public private(set) var accepted_id: Int?
    public private(set) var probability: Int?
    public private(set) var redlistData: [Redlistdata]?
    public private(set) var acceptedTaxon: AcceptedTaxon?
    public private(set) var attributes: Attributes?
    public private(set) var vernacularName_dk: Vernacularname_DK?
    public private(set) var statistics: Statistics?
    public private(set) var images: [Images]?
    
    // This data is made up, not yet known if it exists.
    public private(set) var toxicityLevel: ToxicityLevel? = ToxicityLevel.eatable
 
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt
        case updatedAt
        case path = "Path"
        case systematicPath = "SystematicPath"
        case fullName = "FullName"
        case funIndexCurrUseNumber = "FunIndexCurrUseNumber"
        case funIndexTypificationNumber = "FunIndexTypificationNumber"
        case funIndexNumber = "FunIndexNumber"
        case rankID = "RankID"
        case rankName = "RankName"
        case taxonName = "TaxonName"
        case author = "Author"
        case vernacularName_dk_id = "vernacularname_dk_id"
        case morphogroup_id
        case parent_id
        case accepted_id
        case probability
        case redlistData = "redlistdata"
        case acceptedTaxon
        case attributes
        case vernacularName_dk = "Vernacularname_DK"
        case statistics = "Statistics"
        case images = "Images"
    }
    
    
 }

struct Redlistdata: Decodable {
    public private(set) var status: String?
}

struct AcceptedTaxon: Decodable {
    public private(set) var _id: Int?
    public private(set) var createdAt: String?
    public private(set) var updatedAt: String?
    public private(set) var Path: String?
    public private(set) var SystematicPath: String?
    public private(set) var FullName: String?
    public private(set) var FunIndexCurrUseNumber: Int?
    public private(set) var FunIndexTypificationNumber: Int?
    public private(set) var FunIndexNumber: Int?
    public private(set) var RankID: Int?
    public private(set) var RankName: String?
    public private(set) var TaxonName: String?
    public private(set) var Author: String?
    public private(set) var vernacularname_dk_id: Int?
    public private(set) var morphogroup_id: Int?
    public private(set) var parent_id: Int?
    public private(set) var accepted_id: Int?
    public private(set) var probability: Int?
}

struct Attributes: Decodable {
    public private(set) var PresentInDK: Bool?
    public private(set) var forvekslingsmuligheder: String?
    public private(set) var oekologi: String?
    public private(set) var diagnose: String?
}

struct Vernacularname_DK: Decodable {
    public private(set) var _id: Int?
    public private(set) var taxon_id: Int?
    public private(set) var createdAt: String?
    public private(set) var updatedAt: String?
    public private(set) var vernacularname_dk: String?
    public private(set) var appliedLatinName: String?
    public private(set) var source: String?
    public private(set) var note: String?
}

struct Statistics: Decodable {
    public private(set) var taxon_id: Int
    public private(set) var createdAt: String
    public private(set) var updatedAt: String
    public private(set) var accepted_count: Int
    public private(set) var total_count: Int
    public private(set) var accepted_count_before_atlas: Int
    public private(set) var accepted_count_during_atlas: Int
    public private(set) var accepted_count_after_atlas: Int
    public private(set) var last_accepted_record: String
    public private(set) var first_accepted_record: String
}

struct Images: Decodable {
    public private(set) var _id: Int
    public private(set) var taxon_id: Int
    public private(set) var createdAt: String
    public private(set) var updatedAt: String
    public private(set) var thumburi: String
    public private(set) var uri: String
    public private(set) var photographer: String
    public private(set) var country: String
    public private(set) var collectionNumber: String
}

enum ToxicityLevel: String {
    case toxic = "GIFTIG"
    case eatable = "SPISELIG"
    case cautious = "VÆR FORSIGTIG"
}



