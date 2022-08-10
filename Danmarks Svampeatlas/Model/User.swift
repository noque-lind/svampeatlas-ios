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
    public private(set) var roles: [Role]?
   
    public var imageURL: String? {
        get {
            if let facebookID = facebookID {
                return "https://graph.facebook.com/\(facebookID)/picture?width=250&height=250"
            } else {
                return nil
            }
        }
    }
    
    var isValidator: Bool {
        var isValidator = false
        if let roles = roles {
            for role in roles {
                if role.name == "validator" {
                    isValidator = role.name == "validator"
                    break
                }
            }
        }
        return isValidator
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case initials = "Initialer"
        case email
        case name
        case facebookID = "facebook"
        case roles = "Roles"
    }
    
    init(from cdUser: CDUser) {
        id = Int(cdUser.id)
        name = cdUser.name ?? ""
        initials = cdUser.initials ?? ""
        email = cdUser.email ?? ""
        facebookID = cdUser.facebookID
        if let cdRoles = cdUser.roles?.allObjects as? [CDRole] {
            roles = cdRoles.map({Role.init(name: $0.name ?? "")})
        }
    }
}

struct Role: Decodable, Equatable {
    public private(set) var name: String
}
