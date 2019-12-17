//
//  CoreDataHelper.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 05/07/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import ELKit

enum CoreDataError: AppError {
    var recoveryAction: RecoveryAction? {
        return nil
    }
        
    enum NoEntriesCategory {
        case Substrate
        case VegetationType
        case Mushrooms
        case Hosts
        case User
    }
    
    var errorTitle: String {
        switch self {
        case .contentOutdated:
            return "Databasen skal opdateres"
        case .noEntries:
            return "Fandt intet"
        case .readError:
            return "Læsefejl"
        case .saveError:
            return "Kunne ikke gemme, prøv igen."
        }
    }
    
    var errorDescription: String {
        switch self {
        case .noEntries(category: let category):
            switch category {
            case .Mushrooms:
                return "Du har ingen gemte favoritter. Du kan gøre en svamp til en favorit ved at swippe til venstre."
            default: return "Der var ingen gemt data."
            }
        case .readError:
            return "Der var desværre problemer med at læse data fra disken"
        case .contentOutdated:
            return "Den gemte data er outdated"
        case .saveError:
            return "Gemme-fejl"
        }
    }
    
    
    case noEntries(category: NoEntriesCategory)
    case contentOutdated
    case readError
    case saveError
}

fileprivate class CoreDataService {
    
    static let instance = CoreDataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "SvampeAtlas")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                ELNotificationView.appNotification(style: .error(actions: nil), primaryText: "Database fejl", secondaryText: "Der skete en fejl med at indlæse appen's lokale database. Det betyder du vil opleve problemer med at indlæse lokalt gemt data. Prøv at genstarte appen hvis du oplever problemer, og hvis problemet fortsætter må du meget gerne kontakte app@noque.dk", location: .bottom)
                    .show(animationType: .fromBottom)
            }
        })
        return container
    }()
    
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
}

struct CoreDataHelper {
    
    
    static var managedContext = CoreDataService.instance.managedContext
    
    static func deleteMushroom(mushroom: Mushroom, completion: () -> ()) {
        
       
        
        let fetchRequest = NSFetchRequest<CDMushroom>(entityName: "CDMushroom")
        fetchRequest.predicate = NSPredicate(format: "id == %i", mushroom.id)
        
        do {
            let cdMushrooms = try managedContext.fetch(fetchRequest)
            
            for cdMushroom in cdMushrooms {
                managedContext.delete(cdMushroom)
            }
            try managedContext.save()
            completion()
        } catch {
            print(error)
        }
        
    }
    
    static func fetchAllFavoritedMushrooms() -> Result<[Mushroom], CoreDataError> {
        let fetchRequest = NSFetchRequest<CDMushroom>(entityName: "CDMushroom")
        do {
            let cdMushrooms = try managedContext.fetch(fetchRequest)
            let mushrooms = cdMushrooms.compactMap({Mushroom(from: $0)})
            
            guard mushrooms.count > 0 else {return Result.Error(CoreDataError.noEntries(category: .Mushrooms))}
            return .Success(mushrooms)
        } catch {
            return .Error(.readError)
        }
    }
    
    static func fetchAllFavoritedMushrooms(completion: @escaping (Result<[Mushroom], CoreDataError>) -> ()) {
        CoreDataService.instance.persistentContainer.performBackgroundTask { (context) in
            do {
                let cdMushrooms: [CDMushroom] = try context.fetch(CDMushroom.fetchRequest())
                completion(.Success(cdMushrooms.compactMap({Mushroom(from: $0)})))
            } catch {
                completion(.Error(.readError))
            }
        }
        
        
        let fetchRequest = NSFetchRequest<CDMushroom>(entityName: "CDMushroom")
        do {
            let cdMushrooms = try managedContext.fetch(fetchRequest)
            let mushrooms = cdMushrooms.compactMap({Mushroom(from: $0)})
            
            guard mushrooms.count > 0 else {completion(Result.Error(CoreDataError.noEntries(category: .Mushrooms))); return}
            completion(Result.Success(mushrooms))
        } catch {
            completion(Result.Error(CoreDataError.readError))
        }
    }
    
    
    static func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<Bool, CoreDataError>) -> ()) {
            do {
                let cdMushroom = CDMushroom(context: managedContext)
                cdMushroom.id = Int32(mushroom.id)
                cdMushroom.fullName = mushroom.fullName
                cdMushroom.danishName = mushroom.danishName
                cdMushroom.redlistStatus = mushroom.redlistStatus
                cdMushroom.updatedAt = mushroom.updatedAt
                
                let cdAttributes = CDMushroomAttribute(context: managedContext)
                cdAttributes.diagnosis = mushroom.attributes?.diagnosis
                cdAttributes.ecology = mushroom.attributes?.ecology
                cdAttributes.mushroom = cdMushroom
                cdAttributes.eatability = mushroom.attributes?.eatability
                cdAttributes.mDescription = mushroom.attributes?.description
                cdAttributes.similarities = mushroom.attributes?.similarities
                cdAttributes.tipsForValidation = mushroom.attributes?.tipsForValidation
                
                cdMushroom.attributes = cdAttributes
                
                if let images = mushroom.images {
                    for image in images {
                        let cdImage = CDImage(context: managedContext)
                        cdImage.url = image.url
                        cdImage.photographer = image.photographer
                        cdMushroom.addToImages(cdImage)
                        
                        DispatchQueue.main.async {
                            if !ELFileManager.fileExists(withURL: image.url) {
                                DataService.instance.getImage(forUrl: image.url, size: .full) { (image, imageURL) in
                                    ELFileManager.saveImage(image: image, url: imageURL)
                                }
                            }
                        }
                    }
                }
                
                try managedContext.save()
                completion(Result.Success(true))
            } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(Result.Error(CoreDataError.saveError))
        }
    }
    
    static func mushroomAlreadyFavorited(mushroom: Mushroom) -> Bool {
        let fetchRequest = NSFetchRequest<CDMushroom>(entityName: "CDMushroom")
        fetchRequest.predicate = NSPredicate(format: "id = %i", mushroom.id)
        do {
            let cdMushrooms = try managedContext.fetch(fetchRequest)
            let mushrooms = cdMushrooms.compactMap({Mushroom(from: $0)})
            
            if mushrooms.count == 0 {
                return false
            } else {
                return true
            }
        } catch {
            debugPrint(error)
            return false
        }
    }
}

extension CoreDataHelper {
    // User saving
    
    static func saveUser(user: User) {
            do {
                let cdUser = CDUser(context: managedContext)
                cdUser.id = Int32(user.id)
                cdUser.name = user.name
                cdUser.initials = user.initials
                cdUser.email = user.email
                cdUser.facebookID = user.facebookID
                
        
                if let imageURL = user.imageURL {
                    DataService.instance.getImage(forUrl: imageURL, size: .full, completion: { (image, imageURL) in
                        ELFileManager.saveImage(image: image, url: imageURL)
                    })
                }
        
                    try managedContext.save()
            } catch {
                debugPrint("Could not save user: \(error.localizedDescription)")
            }
}
    
    
    static func fetchUser() -> Result<User, CoreDataError> {
        let fetchRequest = NSFetchRequest<CDUser>(entityName: "CDUser")
        
        do {
            let cdUser = try managedContext.fetch(fetchRequest).last
            
            guard let user = cdUser else {return Result.Error(CoreDataError.noEntries(category: .User))}
            return Result.Success(User(from: user))
        } catch {
            return Result.Error(CoreDataError.noEntries(category: .User))
        }
    }
    
    static func deleteUser() {
        
        do {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDUser")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            debugPrint(error)
        }
    }
    
    

}

extension CoreDataHelper {
    static func fetchVegetationTypes(overrideOutdateWarning: Bool? = false, completion: (Result<[VegetationType], CoreDataError>) -> ()) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.Error(CoreDataError.contentOutdated))
        } else {
            
            let fetchRequest = NSFetchRequest<CDVegetationType>(entityName: "CDVegetationType")
            
            do {
                let cdVegetationTypes = try managedContext.fetch(fetchRequest)
                let vegetationTypes = cdVegetationTypes.compactMap({VegetationType(from: $0)})
                
                guard vegetationTypes.count > 0 else {completion(Result.Error(CoreDataError.noEntries(category: .VegetationType))); return}
                completion(Result.Success(vegetationTypes))
            } catch {
                print(error)
            }
            
        }
    }
    
    static func fetchSubstrateGroup(withID id: Int) -> Substrate? {
        
        let fetchRequest = NSFetchRequest<CDSubstrate>(entityName: "CDSubstrate")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id);
        
        do {
            guard let cdSubstrate = try managedContext.fetch(fetchRequest).first else {return nil}
           return Substrate(from: cdSubstrate)
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func fetchVegetationType(withID id: Int) -> VegetationType? {
        
        let fetchRequest = NSFetchRequest<CDVegetationType>(entityName: "CDVegetationType")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id);
        
        do {
            guard let cdVegetationType = try managedContext.fetch(fetchRequest).first else {return nil}
            return VegetationType(from: cdVegetationType)
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func fetchSubstrateGroups(overrideOutdateWarning: Bool? = false, completion: (Result<[SubstrateGroup], CoreDataError>) -> ()) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.Error(CoreDataError.contentOutdated))
        } else {
            let fetchRequest = NSFetchRequest<CDSubstrateGroup>(entityName: "CDSubstrateGroup")
            
            do {
                let cdSubstrateGroups = try managedContext.fetch(fetchRequest)
                let substrateGroups = cdSubstrateGroups.compactMap({SubstrateGroup(from: $0)})
                
                guard substrateGroups.count > 0 else {completion(Result.Error(CoreDataError.noEntries(category: .Substrate))); return}
                completion(Result.Success(substrateGroups))
            } catch {
                print(error)
            }
        }
    }
    
    static func fetchHosts(overrideOutdateWarning: Bool? = false, completion: (Result<[Host], CoreDataError>) -> ()) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.Error(CoreDataError.contentOutdated))
        } else {
            let fetchRequest = NSFetchRequest<CDHost>(entityName: "CDHost")
            
            
            do {
                let cdHosts = try managedContext.fetch(fetchRequest)
                let hosts = cdHosts.compactMap({Host(from: $0)})
                guard hosts.count > 0 else {completion(Result.Error(CoreDataError.noEntries(category: .Hosts))); return}
                completion(Result.Success(hosts))
            } catch {
                completion(Result.Error(.readError))
            }
        }
    }
    
    static func fetchHost(withID id: Int) -> Host? {
        
        let fetchRequest = NSFetchRequest<CDHost>(entityName: "CDHost")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id);
        
        do {
            guard let cdHost = try managedContext.fetch(fetchRequest).first else {return nil}
            return Host(from: cdHost)
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func saveVegetationTypes(vegetationTypes: [VegetationType]) {
            do {
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDVegetationType.fetchRequest())
                try managedContext.execute(deleteRequest)
                
                for vegetationType in vegetationTypes {
                    let cdVegetationType = CDVegetationType(context: managedContext)
                    cdVegetationType.dkName = vegetationType.dkName
                    cdVegetationType.enName = vegetationType.enName
                    cdVegetationType.id = Int16(vegetationType.id)
                }
                
                try managedContext.save()
                UserDefaultsHelper.databaseWasUpdated()
            } catch {
                debugPrint(error)
            }
    }
    
    static func saveSubstrateGroups(substrateGroups: [SubstrateGroup]) {
            do {
                
                CoreDataService.instance.persistentContainer.performBackgroundTask { (context) in
                    
                }
                
                let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: CDSubstrateGroup.fetchRequest())
                let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: CDSubstrate.fetchRequest())
                try managedContext.execute(deleteRequest1)
                try managedContext.execute(deleteRequest2)
                
                for substrateGroup in substrateGroups {
                    let cdSubstrateGroup = CDSubstrateGroup(context: managedContext)
                    cdSubstrateGroup.dkName = substrateGroup.dkName
                    cdSubstrateGroup.enName = substrateGroup.enName
                    
                    for substrate in substrateGroup.substrates {
                        let cdSubstrate = CDSubstrate(context: managedContext)
                        cdSubstrate.dkName = substrate.dkName
                        cdSubstrate.id = Int16(substrate.id)
                        cdSubstrate.enName = substrate.enName
                        cdSubstrateGroup.addToCdSubstrate(cdSubstrate)
                    }
                }
                
                try managedContext.save()
                UserDefaultsHelper.databaseWasUpdated()
            } catch {
                debugPrint(error)
            }
    }
    
    static func saveHost(userFound: Bool = false, hosts: [Host]) {
        do {
            if !userFound {
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDHost")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                deleteFetch.predicate = NSPredicate(format: "userFound = %@", NSNumber(booleanLiteral: false));
                try managedContext.execute(deleteRequest)
            }
            
            
            
            for host in hosts {
                let cdHost = CDHost(context: managedContext)
                cdHost.id = Int16(host.id)
                cdHost.dkName = host.dkName
                cdHost.latinName = host.latinName
                cdHost.probability = Int64(host.probability)
                cdHost.userFound = userFound
            }
            
            try managedContext.save()
            UserDefaultsHelper.databaseWasUpdated()
        } catch {
            debugPrint(error)
        }
    }
    
    
    
    static func getFavoriteHosts() -> Result<[Host], CoreDataError> {
        return Result.Error(CoreDataError.noEntries(category: .Hosts))
    }
}





