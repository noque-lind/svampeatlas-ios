//
//  Collection+Safe.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 14/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
