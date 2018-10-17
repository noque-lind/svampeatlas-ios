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
    
    enum CodingKeys: String, CodingKey {
        case initials = "Initialer"
        case email
        case name
    }
}
