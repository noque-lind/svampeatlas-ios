//
//  MushroomsRepository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import CoreData

class MushroomsRepository: Repository, RepositoryDelegate {
    
    typealias Item = Mushroom
    
    
    /// Must be called on the main thread
    func fetchAll() -> Result<[Mushroom], CoreDataError> {
        do {
            let cdMushrooms: [CDMushroom] = try mainThread.fetch(NSFetchRequest.init(entityName: "CDMushroom"))
            let mushrooms = cdMushrooms.compactMap({Mushroom(from: $0)})
            
            if mushrooms.isEmpty {
               return .failure(.noEntries(category: .favoritedMushrooms))
            } else {
                return .success(mushrooms)
            }
        } catch {
            debugPrint(error)
            return .failure(.readError)
        }
    }
    
    /// The completion closure is returned on the main thread
    func save(items: [Mushroom], completion: @escaping ((Result<Void, CoreDataError>) -> ())) {
        backgroundThread.perform { [unowned backgroundThread] in
            for item in items {
                let cdMushroom = NSEntityDescription.insertNewObject(forEntityName: "CDMushroom", into: backgroundThread) as! CDMushroom
                cdMushroom.id = Int32(item.id)
                cdMushroom.fullName = item.fullName
                cdMushroom.danishName = item.localizedName
                cdMushroom.redlistStatus = item.redlistStatus
                cdMushroom.updatedAt = item.updatedAt
                
                item.attributes?.toDatabase(cdMushroom: cdMushroom, context: backgroundThread)
                if let images = item.images {
                    for image in images {
                        let cdImage = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: backgroundThread) as! CDImage
                        cdImage.url = image.url
                        cdImage.photographer = image.photographer
                        cdMushroom.addToImages(cdImage)
                        
                        DispatchQueue.global(qos: .background).async {
                            if !ELFileManager.mushroomImageExists(withURL: image.url) {
                                DataService.instance.getImage(forUrl: image.url, size: .full) { (image, imageURL) in
                                    ELFileManager.saveMushroomImage(image: image, url: imageURL)
                                }
                            }
                        }
                    }
                }
            }
            
            do {
                try self.backgroundThread.save()
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
    
    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> ())) {
         backgroundThread.perform { [unowned backgroundThread] in
                    do {
                        let fetchRequest = NSFetchRequest<CDImage>(entityName: "CDImage")
                        let cdImages = try backgroundThread.fetch(fetchRequest)
                        
                        for cdImage in cdImages {
                            guard let url = cdImage.url else {continue}
                            ELFileManager.deleteMushroomImage(withUrl: url)
                        }
                        
                        try backgroundThread.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest.init(entityName: "CDMushroom")))
                        try backgroundThread.save()
                        
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } catch {
                        debugPrint(error)
                        
                        DispatchQueue.main.async {
                            completion(.failure(.saveError))
                        }
                    }
                }
    }
    
    func delete(mushroom: Mushroom, completion: @escaping ((Result<Void, CoreDataError>) -> ())) {
        backgroundThread.perform { [unowned backgroundThread] in
            let fetchRequest: NSFetchRequest<CDMushroom> = CDMushroom.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", mushroom.id)
            
            do {
                let cdMushrooms = try backgroundThread.fetch(fetchRequest)
                cdMushrooms.forEach({
                    ($0.images?.allObjects as? [CDImage])?.forEach({ELFileManager.deleteMushroomImage(withUrl: $0.url ?? "")})
                    backgroundThread.delete($0)})
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
    
    /// Must call this method on the main thread
    func exists(mushroom: Mushroom) -> Bool {
        let fetchRequest: NSFetchRequest<CDMushroom> = CDMushroom.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", mushroom.id)
        
        do {
            let count = try mainThread.count(for: fetchRequest)
            return count > 0 ? true: false
        } catch {
            debugPrint(error)
            return false
        }
    }
}
