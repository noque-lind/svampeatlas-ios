//
//  MushroomsRepository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import Foundation
import PredicateKit

class MushroomsRepository: Repository {
    
    typealias Item = Mushroom
    
    private func getDevice() throws -> CDLocal {
        
        let fetchRequest: NSFetchRequest<CDLocal> = CDLocal.fetchRequest()
        if let cdDevice = (try backgroundThread.fetch(fetchRequest)).first {
            return cdDevice
        } else {
            return CDLocal.init(context: backgroundThread)
            
        }
    }
    
    /// Must be called on the main thread
    func fetchFavorites() -> Result<[Mushroom], CoreDataError> {
            
        do {
            let cdDevice = try getDevice()
            let mushrooms = (cdDevice.mushrooms?.allObjects as? [CDMushroom])?.map({
                Mushroom(from: $0)
            }) ?? []
            
            if mushrooms.isEmpty {
               return .failure(.noEntries(category: .favoritedMushrooms))
            } else {
                return .success(mushrooms)
            }
        } catch {
            return .failure(.readError)
        }
    }
    
    func searchTaxon(searchString: String, completion: @escaping ((Result<[Mushroom], CoreDataError>) -> Void)) {
        backgroundThread.perform {
            do {
                let predicate: Predicate<CDMushroom>
                let speciesSearchResult = SearchStringParser.parseSpeciesSearch(searchString: searchString, unicode: false)
                
                switch Utilities.appLanguage() {
                case .danish:
                    predicate = (\CDMushroom.fullName).contains(searchString) || (\CDMushroom.danishName).contains(searchString) || ((\CDMushroom.fullName).beginsWith(speciesSearchResult.genus) && (\CDMushroom.taxonName).contains(speciesSearchResult.taxonName))
                case .czech:
                    predicate = (\CDMushroom.fullName).contains(searchString) || (\CDMushroom.attributes?.czName).contains(searchString) || ((\CDMushroom.fullName).beginsWith(speciesSearchResult.genus) && (\CDMushroom.taxonName).contains(speciesSearchResult.taxonName))
                case .english:
                    predicate = (\CDMushroom.fullName).contains(searchString) || (\CDMushroom.attributes?.enName).contains(searchString) || ((\CDMushroom.fullName).beginsWith(speciesSearchResult.genus) && (\CDMushroom.taxonName).contains(speciesSearchResult.taxonName))
                }
                                
                let mushrooms: [CDMushroom] =  try self.backgroundThread.fetch(where: predicate).sorted(by: \.probability, .descending).result()
                
                
                if mushrooms.isEmpty {
                    completion(.failure(.noEntries(category: .favoritedMushrooms)))
                } else {
                    completion(.success(mushrooms.map({ Mushroom(from: $0)})))
                }
             
            } catch {
                completion(.failure(.readError))
            }
        }
       
        }
    
    func saveFavorite(_ mushroom: Mushroom, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.perform { [unowned self] in
            do {
                let device = try self.getDevice()
                let mushroom = self.create(mushroom: mushroom, saveImages: true)
                device.addToMushrooms(mushroom)
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
    
    func removeAsFavorite(_ mushroom: Mushroom, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        do {
            guard let cdMushroom = fetch(id: mushroom.id) else {return}
            let device = try getDevice()
            device.removeFromMushrooms(cdMushroom)
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
    
    /// The completion closure is returned on the main thread
    func save(items: [Mushroom], completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.perform { [unowned backgroundThread] in
          // First delete mushrooms, that have no important relationships
            do {
                let deletableMushrooms: [CDMushroom] = try backgroundThread.fetch(where: (\CDMushroom.note).count < 1 && (\CDMushroom.device) == nil).result()
                let favoritedMushrooms: [CDMushroom] = try backgroundThread.fetch(where: !(\CDMushroom.device == nil)).result()
                
                for mushroom in deletableMushrooms {
                    backgroundThread.delete(mushroom)
                }
                
                let filtered = items.filter({ m in
                    return !favoritedMushrooms.contains(where: {m.id == $0.id})
                })
                
                for item in filtered {
                    _ = self.create(mushroom: item, saveImages: false)
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
    
    func fetch(id: Int) -> CDMushroom? {
        let fetchRequest: NSFetchRequest<CDMushroom> = CDMushroom.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        fetchRequest.fetchLimit = 1
        
        do {
            return try backgroundThread.fetch(fetchRequest).first
        } catch {
            return nil
        }
    }
    
    func create(mushroom: Mushroom, saveImages: Bool = false) -> CDMushroom {
        return (NSEntityDescription.insertNewObject(forEntityName: "CDMushroom", into: backgroundThread) as! CDMushroom).then({
            mapValue(item: mushroom, cdMushroom: $0, saveImages: saveImages)
        })
      
    }
    
    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
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
    
    /// Must call this method on the main thread
    func exists(mushroom: Mushroom) -> Bool {
        let local = try? getDevice()
        let some = (local?.mushrooms?.allObjects as? [CDMushroom])?.contains(where: {$0.id == mushroom.id})
        return some ?? false
        
        //
        
        do {
//            let count = try mainThread.count(for: fetchRequest)
//            return count > 0 ? true: false
//        } catch {
//            debugPrint(error)
//            return false
//        }
    }
    }
    
    func mapValue(item: Mushroom, cdMushroom: CDMushroom, saveImages: Bool) {
        cdMushroom.id = Int32(item.id)
        cdMushroom.fullName = item.fullName
        cdMushroom.taxonName = item.taxonName
        cdMushroom.danishName = item.localizedName
        cdMushroom.redlistStatus = item.redlistStatus
        cdMushroom.updatedAt = item.updatedAt
        cdMushroom.acceptedId = Int32(item.acceptedTaxon?.id ?? 0)
        cdMushroom.probability = Int64(item.probability ?? 0)
        
        item.attributes?.toDatabase(cdMushroom: cdMushroom, context: backgroundThread)
        if let images = item.images {
            for (index, image) in images.enumerated() {
                let cdImage = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: backgroundThread) as! CDImage
                cdImage.index = Int16(index)
                cdImage.url = image.url
                cdImage.photographer = image.photographer
                cdMushroom.addToImages(cdImage)
                
                if saveImages {
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
    }
}
