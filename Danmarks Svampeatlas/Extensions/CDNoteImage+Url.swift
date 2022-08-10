//
//  CDNoteImage+Url.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 31/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

extension CDNoteImage {
    var url: URL? {
        guard let filename = filename else {return nil}
        return ELFileManager.createUrl(from: filename)
    }
}
