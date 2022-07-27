//
//  Repository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/01/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import CoreData

protocol RepositoryDelegate {
    associatedtype Item
    
    /// Make sure this function is always called on the main thread.
    func fetchAll() -> Result<[Item], CoreDataError>
    func save(items: [Item], completion: @escaping ((Result<Void, CoreDataError>) -> Void))
    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> Void))
}

open class Repository {
    
    internal let mainThread: NSManagedObjectContext
    internal let backgroundThread: NSManagedObjectContext
    
    init(mainThread: NSManagedObjectContext, backgroundThread: NSManagedObjectContext) {
        self.mainThread = mainThread
        self.backgroundThread = backgroundThread
    }
}
