//
//  UserNotification.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class UserNotificationJSON:Decodable {
    public private(set) var endOfRecords: Bool
    public private(set) var results: [UserNotification]
}

class UserNotification: Decodable {
    public private(set) var observationID: Int
    public private(set) var observationValidation: String
    public private(set) var observationFullName: String
    public private(set) var eventType: String
    public private(set) var date: String
    public private(set) var triggerName: String
    public private(set) var triggerInitials: String
    private(set) var triggerFacebookID: String?
    private(set) var observationImage: String?
    public var imageURL: String? {
        if let triggerFacebookID = triggerFacebookID {
            return "https://graph.facebook.com/\(triggerFacebookID)/picture?width=70&height=70"
        } else if let observationImage = observationImage {
            return "https://svampe.databasen.org/uploads/" + observationImage + ".JPG"
        } else {
            return nil
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case observationID = "observation_id"
        case observationValidation = "validation"
        case observationFullName = "FullName"
        case eventType
        case date = "createdAt"
        case triggerName = "username"
        case triggerInitials = "Initialer"
        case triggerFacebookID = "user_facebook"
        case observationImage = "img"
    }
//    "observation_id": 127964,
//    "observationDate": "2010-10-05T00:00:00.000Z",
//    "observationDateAccuracy": "day",
//    "decimalLatitude": 56.07012,
//    "decimalLongitude": 9.21341,
//    "verbatimLocality": null,
//    "locality": "Nørlund Plantage",
//    "validation": "Godkendt",
//    "score": 6,
//    "FullName": "Lyophyllum shimeji",
//    "Author": "(Kawam.) Hongo",
//    "img": "TB2010PIC46695173",
//    "eventType": "COMMENT_ADDED",
//    "lastRead": "2018-10-30T15:39:34.000Z",
//    "createdAt": "2018-10-31T10:19:57.000Z",
//    "user_id": 57,
//    "username": "Torbjørn Borgen",
//    "Initialer": "TB",
//    "user_facebook": null,
//    "mentioned_id": null,
//    "new_determination_id": null,
//    "new_taxon_id": null,
//    "suggested_name": null
}
