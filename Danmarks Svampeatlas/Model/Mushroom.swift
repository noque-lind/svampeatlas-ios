//
//  Mushroom.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 18/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import UIKit

struct Mushroom: Decodable, Equatable {
    static func == (lhs: Mushroom, rhs: Mushroom) -> Bool {
        return lhs.id == rhs.id
    }
    
    public private(set) var id: Int
    public private(set) var fullName: String
    public private(set) var fullNameAuthor: String?
    public private(set) var updatedAt: String?
    public private(set) var probability: Int?
    public private(set) var rankName: String?
    public private(set) var statistics: Statistics?
    public private(set) var attributes: Attributes?
    private var vernacularNameDK: VernacularNameDK?
    private var redlistData: [RedlistData]?
    private var _images: [Image]?
    
    var danishName: String? {
        get {
            return vernacularNameDK?.vernacularname_dk?.capitalizeFirst()
        }
    }
    
    var redlistStatus: String? {
        get {
            return redlistData?.first?.status
        }
    }
    
    var images: [Image]? {
        if _images?.count != 0 { return _images } else { return nil }
    }
    
    var isGenus: Bool {
        return rankName == "gen."
    }

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "FullName"
        case fullNameAuthor = "Author"
        case updatedAt
        case probability
        case rankName = "RankName"
        
        case vernacularNameDK = "Vernacularname_DK"
        case redlistData = "redlistdata"
        case attributes
        case _images = "Images"
        case statistics = "Statistics"
    }
    
    private init(id: Int, fullName: String) {
        self.id = id
        self.fullName = fullName
    }
    
    init(id: Int, fullName: String, fullNameAuthor: String?, updatedAt: String?, probability: Int?, rankName: String?, statistics: Statistics?, attributes: Attributes?, vernacularNameDK: VernacularNameDK?, redlistData: [RedlistData]?, images: [Image]?) {
        self.id = id
        self.fullName = fullName
        self.fullNameAuthor = fullNameAuthor
        self.updatedAt = updatedAt
        self.probability = probability
        self.rankName = rankName
        self.statistics = statistics
        self.attributes = attributes
        self.vernacularNameDK = vernacularNameDK
        self.redlistData = redlistData
        self._images = images
    }
    
    
    init(from cdMushroom: CDMushroom) {
        id = Int(cdMushroom.id)
        fullName = cdMushroom.fullName ?? "Uventet fejl"
        vernacularNameDK = VernacularNameDK(vernacularname_dk: cdMushroom.danishName, source: nil)
        updatedAt = cdMushroom.updatedAt
        redlistData = [RedlistData(status: cdMushroom.redlistStatus)]
        attributes = Attributes(presentInDenmark: nil, diagnosis: cdMushroom.attributes?.diagnosis, similarities: cdMushroom.attributes?.similarities, ecology: cdMushroom.attributes?.ecology, eatability: cdMushroom.attributes?.eatability, description: cdMushroom.attributes?.mDescription, englishDescription: nil, tipsForValidation: cdMushroom.attributes?.tipsForValidation)
        
        if let cdImages = cdMushroom.images?.allObjects as? [CDImage], cdImages.count != 0 {
            _images = [Image]()
            for cdImage in cdImages {
                guard let url = cdImage.url else {continue}
                _images?.append(Image(thumbURL: nil, url: url, photographer: cdImage.photographer))
            }
        }
    }
    
    static func genus() -> Mushroom {
        return Mushroom(id: 60212, fullName: "Fungi Sp.")
    }
}




struct Attributes: Decodable {
    public private(set) var presentInDenmark: Bool?
    public private(set) var diagnosis: String?
    public private(set) var similarities: String?
    public private(set) var ecology: String?
    public private(set) var eatability: String?
    public private(set) var description: String?
    public private(set) var englishDescription: String?
    public private(set) var tipsForValidation: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case presentInDenmark = "PresentInDK"
        case diagnosis = "diagnose"
        case similarities = "forvekslingsmuligheder"
        case ecology = "oekologi"
        case eatability = "spiselighedsrapport"
        case description = "beskrivelse"
        case englishDescription = "BeskrivelseUK"
        case tipsForValidation = "valideringsrapport"
    }
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

struct Statistics: Decodable {
    public private(set) var acceptedCount: Int?
    public private(set) var lastAcceptedRecord: String?
    public private(set) var firstAcceptedRecord: String?
    
    private enum CodingKeys: String, CodingKey {
        case acceptedCount = "accepted_count"
        case lastAcceptedRecord = "last_accepted_record"
        case firstAcceptedRecord = "first_accepted_record"
    }
}




struct RedlistData: Decodable {
    var status: String?
}




