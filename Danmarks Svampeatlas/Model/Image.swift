//
//  Image.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 02/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct Image: Decodable {
    public private(set) var thumbURL: String?
    public private(set) var url: String
    public private(set) var photographer: String?
    

    private enum CodingKeys: String, CodingKey {
        case thumbURL = "thumburi"
        case url = "uri"
        case photographer
    }
}
