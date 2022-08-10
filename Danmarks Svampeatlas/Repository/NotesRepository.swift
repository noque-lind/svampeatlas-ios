//
//  NotesRepository.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import CoreData

class NotesRepository: Repository, RepositoryDelegate {
    
    typealias Item = CDNote
    
    func fetchAll() -> Result<[CDNote], CoreDataError> {
        do {
            let notes = try mainThread.fetch(CDNote.fetchRequest()) as! [CDNote]
            if notes.count > 0 { return .failure(.noEntries(category: .VegetationType)) }
            return .success(notes)
        } catch {
            return .failure(.readError)
        }
    }
    
    func save(items: [CDNote], completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
                backgroundThread.performAndWait {
                    do {
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
    
    func save(userObservation: UserObservation, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            do {
                let note = create()
                mapValues(note: note, userObservation: userObservation)
                
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
    
    func saveChanges(note: CDNote, userObservation: UserObservation, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            do {
                mapValues(note: note, userObservation: userObservation)
                try backgroundThread.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                     completion(.failure(.saveError))
                }            }
        }
    }
    
    func create() -> CDNote {
        return NSEntityDescription.insertNewObject(forEntityName: "CDNote", into: backgroundThread) as! CDNote
    }
    
    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        
    }
    
    func delete(note: CDNote, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundThread.performAndWait {
            do {
                (note.images?.allObjects as? [CDNoteImage])?.forEach({
                    guard let url = $0.url else {return}
                    ELFileManager.deleteImage(imageURL: url)
                })
            backgroundThread.delete(note)
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
    
    func getController() -> NSFetchedResultsController<CDNote> {
        let fetchRequest = NSFetchRequest<CDNote>.init(entityName: "CDNote")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
 
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: backgroundThread, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func mapValues(note: CDNote, userObservation: UserObservation) {
        if note.creationDate == nil {
            note.creationDate = Date()
        }
  
        note.observationDate = userObservation.observationDate
        note.note = userObservation.note
        note.ecologyNote = userObservation.ecologyNote
        if let mushroom = userObservation.mushroom {
            note.specie = Database.instance.mushroomsRepository.fetch(id: mushroom.id) ?? Database.instance.mushroomsRepository.create(mushroom: mushroom, saveImages: false)
            note.confidence = userObservation.determinationConfidence.rawValue
        } else {
            note.specie = nil
            note.confidence = nil
        }
        
        if let substrate = userObservation.substrate {
            note.substrate = try? Database.instance.substrateGroupsRepository.find(substrate: substrate) ?? Database.instance.substrateGroupsRepository.create(substrate: substrate)
        }
        
        if let vegetationType = userObservation.vegetationType {
            note.vegetationType = Database.instance.vegetationTypeRepository.create(vegetationType)
        }
        
        if let locality = userObservation.locality {
            note.locality = locality.locality.toCD(context: backgroundThread)
        }
        
        if let observationLocation = userObservation.observationLocation {
            note.location = observationLocation.item.toCD(context: backgroundThread)
        }
        
        note.images?.allObjects.forEach({
            backgroundThread.delete($0 as! CDNoteImage)
        })
        
        note.hosts?.allObjects.forEach({note.removeFromHosts($0 as! CDHost)})
        
        userObservation.hosts.forEach({
            let cdHost = CDHost(context: backgroundThread)
            cdHost.id = Int16($0.id)
            cdHost.dkName = $0.dkName
            cdHost.latinName = $0.latinName
            cdHost.probability = Int64($0.probability)
            
            note.addToHosts(cdHost)
        })
        
        let locallyStored = userObservation.images.compactMap({$0.type == .locallyStored ? $0.filename: nil})
        let newImages = userObservation.images.compactMap({$0.type == .new ? $0.url: nil}).map({
            ELFileManager.saveNoteImage(image: $0)
        })
        
        (locallyStored + newImages).forEach({
            let cdNoteImage = CDNoteImage.init(context: backgroundThread)
                cdNoteImage.filename = $0
                note.addToImages(cdNoteImage)
            note.addToImages(cdNoteImage)
        })
    }
    
//    func fetchAll() -> Result<[VegetationType], CoreDataError> {
//        do {
//            let cdVegetationTypes: [CDVegetationType] = try mainThread.fetch(CDVegetationType.fetchRequest())
//            let vegetationTypes = cdVegetationTypes.compactMap({VegetationType.init(from: $0)})
//            return .success(vegetationTypes)
//        } catch {
//            return .failure(.readError)
//        }
//    }
//
//
//    typealias Item = VegetationType
//
//    func deleteAll(completion: @escaping ((Result<Void, CoreDataError>) -> ())) {
//        backgroundThread.performAndWait {
//            do {
//                try backgroundThread.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest.init(entityName: "CDVegetationType")))
//                try backgroundThread.save()
//                DispatchQueue.main.async {
//                    completion(.success(()))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(.saveError))
//                }
//            }
//        }
//    }
//
//    func save(items: [VegetationType], completion: @escaping ((Result<Void, CoreDataError>) -> ())) {
//        backgroundThread.performAndWait {
//            do {
//                for item in items {
//                    let object = NSEntityDescription.insertNewObject(forEntityName: "CDVegetationType", into: backgroundThread) as! CDVegetationType
//                    object.dkName = item.dkName
//                    object.enName = item.enName
//                    object.id = Int16(item.id)
//
//                }
//                try backgroundThread.save()
//                DispatchQueue.main.async {
//                    completion(.success(()))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                     completion(.failure(.saveError))
//                }
//            }
//        }
//    }
}
