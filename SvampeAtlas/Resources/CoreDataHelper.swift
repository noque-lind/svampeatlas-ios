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

struct CoreDataHelper {
    static func deleteMushroom(mushroom: Mushroom, completion: () -> ()) {
        guard let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
       
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
    
    static func fetchAll(completion: (_ mushrooms: [Mushroom]) -> ()) {
        guard let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {return}
        
        let fetchRequest = NSFetchRequest<CDMushroom>(entityName: "CDMushroom")
        do {
        let cdMushrooms = try managedContext.fetch(fetchRequest)
            let mushrooms = cdMushrooms.compactMap({Mushroom(from: $0)})
            completion(mushrooms)
        } catch {
            completion([Mushroom]())
        }
    }
    
    static func saveMushroom(mushroom: Mushroom, completion: @escaping () -> ()) {
        guard let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {return}
        
        do {
        
        let cdMushroom = CDMushroom(context: managedContext)
        cdMushroom.id = Int32(mushroom.id)
        cdMushroom.fullName = mushroom.fullName
        cdMushroom.danishName = mushroom.danishName
        cdMushroom.redlistStatus = mushroom.redlistData?.status
        cdMushroom.updatedAt = mushroom.updatedAt
        
            let cdAttributes = CDMushroomAttribute(context: managedContext)
            cdAttributes.diagnosis = mushroom.attributes?.diagnosis
            cdAttributes.ecology = mushroom.attributes?.ecology
            cdAttributes.mushroom = cdMushroom
        
        cdMushroom.attributes = cdAttributes

            if let images = mushroom.images {
                for image in images {
                    let cdImage = CDImage(context: managedContext)
                    cdImage.url = image.url
                    cdImage.photographer = image.photographer
                    cdMushroom.addToImages(cdImage)
                    
                    if !FileManager.default.fileExists(atPath: (FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!.appendingPathComponent(image.url).absoluteString)) {
                        let filePath = (FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]).appendingPathComponent(image.url)
                        
                        DataService.instance.getImage(forUrl: image.url) { (image) in
                            let data = image.pngData()
                            try? data?.write(to: filePath)
                        }
                    }
                }
            }
        
            try managedContext.save()
            completion()
        
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion()
        }
        }
    }


    

    
