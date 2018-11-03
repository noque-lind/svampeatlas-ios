//
//  User.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 28/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct User: Decodable, Equatable {
    public private(set) var id: Int
    public private(set) var name: String
    public private(set) var initials: String
    public private(set) var email: String
    public private(set)  var facebookID: String?
   
    public var imageURL: String? {
        get {
            if let facebookID = facebookID {
                return "https://graph.facebook.com/\(facebookID)/picture?width=250&height=250"
            } else {
                return nil
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case initials = "Initialer"
        case email
        case name
        case facebookID = "facebook"
    }
    
    init(from cdUser: CDUser) {
        id = Int(cdUser.id)
        name = cdUser.name ?? ""
        initials = cdUser.initials ?? ""
        email = cdUser.email ?? ""
        facebookID = cdUser.facebookID
    }
}
