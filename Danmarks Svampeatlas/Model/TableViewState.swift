//
//  TableViewState.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

enum TableViewState<T> {
    case Loading
    case Error(AppError, (() ->())?)
    case Items([T])
    case Paging(items: [T], max: Int?)
    case Empty
    case None
    
    func value(row: Int) -> T? {
        switch self {
        case .Items(let items):
            guard items.endIndex > row else {return nil}
            return items[row]
        case .Paging(items: let items, _):
            guard items.endIndex > row else {return nil}
            return items[row]
        default:
            return nil
        }
    }
    
    func itemsCount() -> Int {
        switch self {
        case .Items(let items):
            return items.count
        case .Paging(items: let items, _):
            return items.count
        default:
            return 0
        }
    }
    
    func currentItems() -> [T] {
        switch self {
        case .Items(let items):
            return items
        case .Paging(items: let items, max: _):
            return items
        default:
            return []
        }
    }
}
