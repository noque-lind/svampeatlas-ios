//
//  TableViewState.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import Foundation

class Section<T>: Hashable {
    
    static func == (lhs: Section<T>, rhs: Section<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid.hashValue)
    }

    enum State {
        case items(items: [T])
        case loading
        case error(error: AppError, handler: ((RecoveryAction?) -> Void)? = nil)
        case empty
    }
    
    private let uid: UUID
    private var _title: String?
    var title: String? {
        get {
            switch state {
            case .empty: return nil
            default: return _title
            }
        }
    }
    
    public private(set) var state: State
    
    init(title: String?, state: State) {
        self.uid = UUID()
        self._title = title
        self.state = state
    }
    
    func count() -> Int {
        switch state {
        case .error:
            return 1
        case .items(items: let items):
            return items.count
        case .loading:
            return 1
        case .empty:
            return 0
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
        self._title = title
    }
    
    func setState(state: State) {
        self.state = state
    }
}

enum TableViewState<T> {
    case Loading
    case Error(AppError, ((RecoveryAction?) -> Void)?)
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
