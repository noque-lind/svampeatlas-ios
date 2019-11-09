//
//  TableViewState.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class Section<T> {
    
    enum State {
        case items(items: [T])
        case loading
        case error(error: AppError)
    }
    
    public private(set) var title: String?
    public private(set) var state: State
    
    init(title: String?, state: State) {
        self.title = title
        self.state = state
    }
    
    func count() -> Int {
        switch state {
        case .error(_):
            return title != nil ? 2: 1
        case .items(items: let items):
            return title != nil ? items.count + 1: items.count
        case .loading:
            return title != nil ? 2: 1
        }
    }
    
    func itemAt(index: Int) -> T? {
        if case State.items(items: let items) = state {
            return items[safe: index]
        } else {
            return nil
        }
    }
    
    func removeItemAt(index: Int) {
        if case State.items(items: var items) = state {
            items.remove(at: index)
            state = .items(items: items)
        }
    }
    
    
    func setTitle(title: String?) {
        self.title = title
    }
    
    func setState(state: State) {
        self.state = state
    }
}

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
