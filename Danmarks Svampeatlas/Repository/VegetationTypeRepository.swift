//
//  VegetationtypeRepository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/01/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import CoreData

class VegetationTypeRepository: Repository, RepositoryDelegate {
    
    func fetchAll() -> Result<[VegetationType], CoreDataError> {
        do {
            let cdVegetationTypes: [CDVegetationType] = try mainThread.fetch(CDVegetationType.fetchRequest())
            let vegetationTypes = cdVegetationTypes.compactMap({VegetationType.init(from: $0)})
            return .success(vegetationTypes)
        } catch {
            return .failure(.readError)
        }
    }
    
    typealias Item = VegetationType
    
    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            do {
                try backgroundThread.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest.init(entityName: "CDVegetationType")))
                try backgroundThread.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveError))
                }
            }
        }
    }
    
    func save(items: [VegetationType], completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            do {
                for item in items {
                    _ = create(item)
                }
                try backgroundThread.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                     completion(.failure(.saveError))
                }
            }
        }
    }
    
    func create(_ item: VegetationType) -> CDVegetationType {
        return (NSEntityDescription.insertNewObject(forEntityName: "CDVegetationType", into: backgroundThread) as! CDVegetationType).then({
            $0.dkName = item.dkName
            $0.enName = item.enName
            $0.id = Int16(item.id)
        })
    }
}
