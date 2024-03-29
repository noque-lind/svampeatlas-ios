//
//  SubstrateGroupsRepository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 30/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import Foundation
import PredicateKit

class SubstrateGroupsRepository: Repository, RepositoryDelegate {
    
    typealias Item = SubstrateGroup
    
    func deleteAll(completion: ((Result<Void, CoreDataError>) -> Void)) {        
        backgroundThread.performAndWait {
            do {
                try backgroundThread.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest.init(entityName: "CDSubstrateGroup")))
                try backgroundThread.save()
                completion(.success(()))
            } catch {
                completion(.failure(.saveError))
            }
        }
    }
    
    func save(items: [SubstrateGroup], completion: ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            for item in items {
                let _: CDSubstrateGroup = {
                    let object = NSEntityDescription.insertNewObject(forEntityName: "CDSubstrateGroup", into: backgroundThread) as! CDSubstrateGroup
                    object.dkName = item.dkName
                    object.enName = item.enName
                    
                    for substrate in item.substrates {
                        object.addToCdSubstrate(create(substrate: substrate))
                    }
                    return object
                }()
            }
            
            do {
                try backgroundThread.save()
                UserDefaultsHelper.databaseWasUpdated()
                completion(.success(()))
            } catch {
                debugPrint(error)
                completion(.failure(.saveError))
            }
        }
    }
    
    func fetchAll() -> Result<[SubstrateGroupsRepository.Item], CoreDataError> {
        do {
            let cdSubstrateGroups: [CDSubstrateGroup] = try mainThread.fetch(CDSubstrateGroup.fetchRequest())
            let substrateGroups = cdSubstrateGroups.compactMap({SubstrateGroup(from: $0)})
            
            if substrateGroups.isEmpty {
                return .failure(.noEntries(category: .Substrate))
            } else {
                return .success(substrateGroups)
            }
        } catch {
            return .failure(.readError)
        }
    }
    
    func fetchSubstratesOnly() -> Result<[Substrate], CoreDataError> {
        do {
            let cdSubstrates: [CDSubstrate] = try mainThread.fetch(CDSubstrate.fetchRequest())
            let substrates = cdSubstrates.compactMap({Substrate.init(from: $0)})
            
            if substrates.isEmpty {
              return .failure(.noEntries(category: .Substrate))
                } else {
                return .success(substrates)
                }
        } catch {
            return .failure(.readError)
        }
    }
    
    func fetch(overrideOutdateWarning: Bool? = false) -> Result<[SubstrateGroup], CoreDataError> {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            return .failure(CoreDataError.contentOutdated)
        } else {
            return fetchAll()
        }
    }
    
    func find(substrate: Substrate) throws -> CDSubstrate? {
        let substrates: [CDSubstrate] = try backgroundThread.fetch(where: \CDSubstrate.id == Int16(substrate.id)).result()
        return substrates.first
    }
    
    func create(substrate: Substrate) -> CDSubstrate {
        return (NSEntityDescription.insertNewObject(forEntityName: "CDSubstrate", into: backgroundThread) as! CDSubstrate).then({
            $0.dkName = substrate.dkName
            $0.id = Int16(substrate.id)
            $0.enName = substrate.enName
        })
    }
}
