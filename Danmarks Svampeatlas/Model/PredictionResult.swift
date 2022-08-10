//
//  PredictionResult.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 08/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct PredictionResult: Decodable {
    private(set) var id: Int
    public private(set) var score: Double
    private var acceptedTaxon: AcceptedTaxon
    private var vernacularNameDK: VernacularNameDK?
    private var attributes: Attributes?
    private var statistics: Statistics?
    private var redlistData: [RedlistData]?
    private var images: [Image]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case score = "score"
        case acceptedTaxon = "acceptedTaxon"
        case vernacularNameDK = "Vernacularname_DK"
        case attributes = "attributes"
        case statistics = "Statistics"
        case redlistData = "redlistdata"
        case images = "Images"
    }
    
    var mushroom: Mushroom {
        return Mushroom(id: id, fullName: acceptedTaxon.fullName, fullNameAuthor: nil, updatedAt: nil, probability: nil, rankName: nil, statistics: statistics, attributes: attributes, vernacularNameDK: vernacularNameDK, redlistData: redlistData, images: images)
}
}
