//
//  User.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 28/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct User: Decodable {
    public private(set) var name: String
    public private(set) var initials: String
    public private(set) var email: String
    public private(set) var facebookID: String?
   
    public var imageURL: String? {
        get {
            if let facebookID = facebookID {
                return "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=\(facebookID)&height=200&width=200&ext=1543004373&hash=AeTELec4XBoSPCBU"
            } else {
                return nil
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case initials = "Initialer"
        case email
        case name
        case facebookID = "facebook"
    }
}
