//
//  CoreDataHelper.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 05/07/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import ELKit
import Foundation
import UIKit

enum CoreDataError: AppError {
    var recoveryAction: RecoveryAction? {
        switch self {
        case .initError:
            return .tryAgain
        default: return nil
        }
    }
    
    enum NoEntriesCategory {
        case Substrate
        case VegetationType
        case favoritedMushrooms
        case Hosts
        case User
        case Notes
    }
    
    var title: String {
        switch self {
        case .initError: return NSLocalizedString("databaseError_initError_title", comment: "")
        case .contentOutdated:
            return NSLocalizedString("databaseError_contentOutdated_title", comment: "")
        case .noEntries:
            return NSLocalizedString("databaseError_noEntries_title", comment: "")
        case .readError:
            return NSLocalizedString("databaseError_readError_title", comment: "")
        case .saveError:
            return NSLocalizedString("databaseError_saveError_title", comment: "")
        }
    }
    
    var message: String {
        switch self {
        case .initError: return NSLocalizedString("databaseError_initError_message", comment: "")
        case .noEntries(category: let category):
            switch category {
            case .favoritedMushrooms:
                return NSLocalizedString("databaseError_noEntries_favoritedMushrooms_message", comment: "")
            case .Notes:
                return NSLocalizedString("notebook_message", comment: "")
            default: return NSLocalizedString("databaseError_noEntries_message", comment: "")
            }
        case .readError:
            return NSLocalizedString("databaseError_readError_message", comment: "")
        case .contentOutdated:
            return NSLocalizedString("databaseError_contentOutdated_message", comment: "")
        case .saveError:
            return NSLocalizedString("databaseError_saveError_message", comment: "")
        }
    }
    
    case noEntries(category: NoEntriesCategory)
    case contentOutdated
    case readError
    case saveError
    case initError
}

class Database {
    
    static let instance = Database(type: .production)
    
    enum `Type` {
        case production
        case test
    }
    
    let persistentContainer: NSPersistentContainer
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    fileprivate lazy var mainContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    let type: Type
    
    lazy var mushroomsRepository: MushroomsRepository = {
        return MushroomsRepository(mainThread: mainContext, backgroundThread: backgroundContext)
    }()
    
    lazy var substrateGroupsRepository: SubstrateGroupsRepository = {
        return SubstrateGroupsRepository(mainThread: mainContext, backgroundThread: backgroundContext)
    }()
    
    lazy var vegetationTypeRepository: VegetationTypeRepository = {
        return VegetationTypeRepository(mainThread: mainContext, backgroundThread: backgroundContext)
    }()
    
    lazy var notesRepository: NotesRepository = {
        return NotesRepository(mainThread: mainContext, backgroundThread: backgroundContext)
    }()
    
    init(type: Type) {
        self.type = type
        
        let persistentContainer: NSPersistentContainer = {
            let pc = NSPersistentContainer(name: "SvampeAtlas")
            switch type {
            case .production: pc.persistentStoreDescriptions.first?.type = NSSQLiteStoreType
            case .test: pc.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
            }
            
            return pc
        }()
        
        self.persistentContainer = persistentContainer
    }
    
    func reset() {
        backgroundContext.reset()
        mainContext.reset()
    }
    
    func setup(completion: (() -> Void)?) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let _ = error as NSError? {
                ELNotificationView.appNotification(style: .error(actions: [.neutral(CoreDataError.initError.recoveryAction?.localizableText, {
                    UserDefaultsHelper.lastDataUpdateDate = nil
                    
                    guard let url = self.persistentContainer.persistentStoreDescriptions.first?.url else {return}
                    try? self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
                    self.persistentContainer.persistentStoreCoordinator.addPersistentStore(with: storeDescription, completionHandler: { (_, _) in
                        completion?()
                    })
                })]), primaryText: CoreDataError.initError.title, secondaryText: CoreDataError.initError.message, location: .bottom)
                .show(animationType: .fromBottom)
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
}

struct CoreDataHelper {
    
    static var managedContext = Database.instance.mainContext
    
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
            
            if let roles = user.roles {
                roles.forEach({ role in
                    cdUser.addToRoles(CDRole.init(context: managedContext).then({$0.name = role.name}))
                })
            }
            
            if let imageURL = user.imageURL {
                DataService.instance.getImage(forUrl: imageURL, size: .full, completion: { (image, imageURL) in
                    ELFileManager.saveMushroomImage(image: image, url: imageURL)
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
            
            guard let user = cdUser else {return Result.failure(CoreDataError.noEntries(category: .User))}
            return Result.success(User(from: user))
        } catch {
            return Result.failure(CoreDataError.noEntries(category: .User))
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
    static func fetchVegetationTypes(overrideOutdateWarning: Bool? = false, completion: (Result<[VegetationType], CoreDataError>) -> Void) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.failure(CoreDataError.contentOutdated))
        } else {
            
            let fetchRequest = NSFetchRequest<CDVegetationType>(entityName: "CDVegetationType")
            
            do {
                let cdVegetationTypes = try managedContext.fetch(fetchRequest)
                let vegetationTypes = cdVegetationTypes.compactMap({VegetationType(from: $0)})
                
                guard vegetationTypes.count > 0 else {completion(Result.failure(CoreDataError.noEntries(category: .VegetationType))); return}
                completion(Result.success(vegetationTypes))
            } catch {
                print(error)
            }
            
        }
    }
    
    static func fetchSubstrateGroup(withID id: Int) -> Substrate? {
        
        let fetchRequest = NSFetchRequest<CDSubstrate>(entityName: "CDSubstrate")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
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
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
        do {
            guard let cdVegetationType = try managedContext.fetch(fetchRequest).first else {return nil}
            return VegetationType(from: cdVegetationType)
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    static func fetchSubstrateGroups(overrideOutdateWarning: Bool? = false, completion: @escaping (Result<[SubstrateGroup], CoreDataError>) -> Void) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.failure(CoreDataError.contentOutdated))
        } else {
            Database.instance.persistentContainer.performBackgroundTask { (context) in
                do {
                    let cdSubstrateGroups: [CDSubstrateGroup] = try context.fetch(CDSubstrateGroup.fetchRequest())
                    let substrateGroups = cdSubstrateGroups.compactMap({SubstrateGroup(from: $0)})
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if !substrateGroups.isEmpty {
                            completion(.success(substrateGroups))
                        } else {
                            completion(.failure(.noEntries(category: .Substrate)))
                        }
                    }
                } catch {
                    DispatchQueue.global(qos: .userInitiated).async {
                        completion(.failure(.readError))
                    }
                }
            }
        }
    }
    
    static func fetchHosts(overrideOutdateWarning: Bool? = false, completion: (Result<[Host], CoreDataError>) -> Void) {
        if UserDefaultsHelper.shouldUpdateDatabase && overrideOutdateWarning == false {
            completion(Result.failure(CoreDataError.contentOutdated))
        } else {
            let fetchRequest = NSFetchRequest<CDHost>(entityName: "CDHost")
            
            do {
                let cdHosts = try managedContext.fetch(fetchRequest)
                let hosts = cdHosts.compactMap({Host(from: $0)})
                guard hosts.count > 0 else {completion(Result.failure(CoreDataError.noEntries(category: .Hosts))); return}
                completion(Result.success(hosts))
            } catch {
                completion(Result.failure(.readError))
            }
        }
    }
    
    static func fetchHost(withID id: Int) -> Host? {
        
        let fetchRequest = NSFetchRequest<CDHost>(entityName: "CDHost")
        fetchRequest.predicate = NSPredicate(format: "id = %i", id)
        
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
    
    static func deleteSubstrateGroups() -> Bool {
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: CDSubstrateGroup.fetchRequest())
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: CDSubstrate.fetchRequest())
        do {
            try managedContext.execute(deleteRequest1)
            try managedContext.execute(deleteRequest2)
            return true
        } catch {
            return false
        }
    }
    
    static func saveSubstrateGroups(substrateGroups: [SubstrateGroup]) {
        do {
            
            Database.instance.persistentContainer.performBackgroundTask { (_) in
                _ = deleteSubstrateGroups()
                
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
                deleteFetch.predicate = NSPredicate(format: "userFound = %@", NSNumber(booleanLiteral: false))
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
        return Result.failure(CoreDataError.noEntries(category: .Hosts))
    }
}
