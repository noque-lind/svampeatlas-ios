//
//  Mushroom.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 18/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import Foundation
import UIKit

struct Mushroom: Decodable, Equatable {
    static func == (lhs: Mushroom, rhs: Mushroom) -> Bool {
        return lhs.id == rhs.id
    }
    
    public private(set) var isPlaceholder: Bool = false
    
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
    
    var localizedName: String? {
        switch Utilities.appLanguage() {
        case .danish: return vernacularNameDK?.vernacularname_dk?.capitalizeFirst()
        case .english: return attributes?.enName?.capitalizeFirst()
        case .czech: return attributes?.czName?.capitalizeFirst()
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
    
    private init(id: Int, fullName: String, isGenus: Bool) {
        self.rankName = "gen."
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
    
    init(id: Int, fullName: String) {
        self.init(id: id, fullName: fullName, fullNameAuthor: nil, updatedAt: nil, probability: nil, rankName: nil, statistics: nil, attributes: nil, vernacularNameDK: nil, redlistData: nil, images: nil)
        isPlaceholder = true
    }
    
    init(from cdMushroom: CDMushroom) {
        id = Int(cdMushroom.id)
        fullName = cdMushroom.fullName ?? "[...]"
        vernacularNameDK = VernacularNameDK(vernacularname_dk: cdMushroom.danishName, source: nil)
        updatedAt = cdMushroom.updatedAt
        redlistData = [RedlistData(status: cdMushroom.redlistStatus)]

        if let cdAttributes = cdMushroom.attributes {
            attributes = Attributes(cdAttributes)
        }

        if let cdImages = cdMushroom.images?.allObjects as? [CDImage], cdImages.count != 0 {
            _images = [Image]()
            for cdImage in cdImages {
                guard let url = cdImage.url else {continue}
                _images?.append(Image(id: id, thumbURL: nil, url: url, photographer: cdImage.photographer))
            }
        }
    }
    
    static func genus() -> Mushroom {
        return Mushroom(id: 60212, fullName: "Fungi Sp.", isGenus: true)
    }
}

struct Attributes: Decodable {
    public private(set) var presentInDenmark: Bool?
    private let _similarities: String?
    private let _ecology: String?
    private let _eatability: String?
    private let _tipsForValidation: String?
    fileprivate let czName: String?
    fileprivate let enName: String?
    fileprivate let dkDescription: String?
    fileprivate let enDescription: String?
    fileprivate let czDescription: String?
    
    private enum CodingKeys: String, CodingKey {
        case presentInDenmark = "PresentInDK"
        case _similarities = "forvekslingsmuligheder"
        case _ecology = "oekologi"
        case _eatability = "spiselighedsrapport"
        case dkDescription = "bogtekst_gyldendal"
        case enDescription = "bogtekst_gyldendal_en"
        case czDescription = "bogtekst_gyldendal_cz"
        case _tipsForValidation = "valideringsrapport"
        case enName = "vernacular_name_GB"
        case czName = "vernacular_name_CZ"
    }
    
    var description: String? {
        switch Utilities.appLanguage() {
        case .czech: return czDescription?.capitalizeFirst()
        case .danish: return dkDescription?.capitalizeFirst()
        case .english: return enDescription?.capitalizeFirst()
        }
    }
    
    var eatability: String? {
        switch Utilities.appLanguage() {
        case .czech: return nil
        case .danish: return _eatability?.capitalizeFirst()
        case .english: return nil
        }
    }
    
    var similarities: String? {
        switch Utilities.appLanguage() {
        case .czech: return nil
        case .danish: return _similarities?.capitalizeFirst()
        case .english: return nil
        }
    }
    
    var ecology: String? {
        switch Utilities.appLanguage() {
        case .czech: return nil
        case .danish: return _ecology?.capitalizeFirst()
        case .english: return nil
        }
    }
    
    var tipsForValidation: String? {
        switch Utilities.appLanguage() {
        case .czech: return nil
        case .danish: return _tipsForValidation?.capitalizeFirst()
        case .english: return nil
        }
    }
    
    var isPoisonous: Bool {
        if let eatability = _eatability, eatability.lowercased().contains("giftig") && !eatability.lowercased().contains("ikke giftig") {
            return true
        } else {
            return false
        }
    }
    
//    init(presentInDenmark: Bool?, similarities: String?, ecology: String?, eatability: String?, tipsForValidation: String?, enName: String?, diagnosis: String?, diagnosisEn: String?) {
//        self.presentInDenmark = presentInDenmark
//        self._similarities = similarities
//        self._ecology = ecology
//        self._eatability = eatability
//        self._tipsForValidation = tipsForValidation
//        self.enName =
//        self.vernacularNameEN = vernacularNameEN
//        self._diagnosis = diagnosis
//        self._diagnosisEn = diagnosisEn
//    }
    
    init(_ model: CDMushroomAttribute) {
        self.presentInDenmark = nil
        self.czName = model.czName
        self.enName = model.enName
        self.dkDescription = model.mDescription
        self.enDescription = model.mDescriptionEN
        self.czDescription = nil
        self._ecology = model.ecology
        self._eatability = model.eatability
        self._similarities = model.similarities
        self._tipsForValidation = model.tipsForValidation
    }
    
    func toDatabase(cdMushroom: CDMushroom, context: NSManagedObjectContext) {
        let cdAttributes = NSEntityDescription.insertNewObject(forEntityName: "CDMushroomAttribute", into: context)  as! CDMushroomAttribute
        cdAttributes.ecology = _ecology
        cdAttributes.similarities = _similarities
        cdAttributes.tipsForValidation = _tipsForValidation
        cdAttributes.eatability = _eatability
        cdAttributes.mushroom = cdMushroom
        cdAttributes.czName = czName
        cdAttributes.enName = enName
        cdAttributes.mDescription = dkDescription
        cdAttributes.mDescriptionEN = enDescription
    }
   
}

enum ToxicityLevel: String {
    case toxic = "GIFTIG"
    
    var description: String {
        switch self {
        case .toxic: return NSLocalizedString("toxicityLevel_poisonous", comment: "")
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
