//
//  UserDefaultsHelper.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 19/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

struct UserDefaultsHelper {
    static var hasSeenWhatsNew: Bool {
        get {
            if let lastOpenedVersion = UserDefaults.standard.string(forKey: "lastOpenedVersion") {
                return lastOpenedVersion == UIApplication.currentVersion()
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(UIApplication.currentVersion(), forKey: "lastOpenedVersion")
        }
    }
    
    
    private static var localityLockedDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "localityLockedDate") as? Date
        } set {
                if let newValue = newValue  {
                    UserDefaults.standard.set(newValue, forKey: "localityLockedDate")
                } else {
                    UserDefaults.standard.removeObject(forKey: "localityLockedDate")
                }
        }
    }
    
    private static var locationLockedDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "locationLockedDate") as? Date
        } set {
            if newValue != nil {
                UserDefaults.standard.set(newValue, forKey: "locationLockedDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "locationLockedDate")
            }
        }
    }
    
    
    static var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        } set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "token")
            }
        }
    }
    
    static var offlineDatabasePresent: Bool {
        return UserDefaults.standard.object(forKey: "databaseLastUpdatedDate") != nil
    }
    
    static var shouldUpdateDatabase: Bool {
        get {
            guard let databaseLastUpdatedDate = UserDefaults.standard.object(forKey: "databaseLastUpdatedDate") as? Date else {return true}
            
            let day = Calendar.current.dateComponents([.day], from: databaseLastUpdatedDate, to: Date()).day
            if day ?? 0 < 30 {
                return false
            } else {
                return true
            }
        }
        set {
            if newValue == true {
                UserDefaults.standard.set(Date(age: 4), forKey: "databaseLastUpdatedDate")
            } else {
                UserDefaults.standard.set(Date(), forKey: "databaseLastUpdatedDate")
            }
        }
    }
    
    static var defaultVegetationTypeID: Int? {
        let vegetationTypeID = UserDefaults.standard.integer(forKey: "defaultVegetationTypeID")
        
        if vegetationTypeID > 0 {
            return vegetationTypeID
        } else {
            return nil
        }
    }
    
    static var defaultSubstrateID: Int? {
        let substrateID = UserDefaults.standard.integer(forKey: "defaultSubstrateID")
        
        if substrateID > 0 {
            return substrateID
        } else {
            return nil
        }
    }
    
    static var defaultHostsIDS: [Int]? {
        if let ids = UserDefaults.standard.array(forKey: "defaultHostsIDS") as? [Int], ids.count > 0 {
            return ids
        } else {
            return nil
        }
    }
    
    static var lockedLocality: Locality? {
        get {
            // If locality was locked over 1 hour ago, do not return the locality
            guard let localityLockedDate = localityLockedDate, Calendar.current.dateComponents([.hour], from: localityLockedDate).hour ?? 1 >= 1 else {return nil}
            if let data = UserDefaults.standard.data(forKey: "LockedLocality") {
                return try? JSONDecoder().decode(Locality.self, from: data)
            } else {
                return nil
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "LockedLocality")
                localityLockedDate = Date()
            } else {
                UserDefaults.standard.removeObject(forKey: "LockedLocality")
                localityLockedDate = nil
            }
        }
    }
    
    static var lockedLocation: CLLocation? {
        get {
            // If location was locked over 1 hour ago, do not return the locality
            guard let locationLockedDate = locationLockedDate, Calendar.current.dateComponents([.hour], from: locationLockedDate).hour ?? 1 >= 1 else {return nil}
            if let loadedLocation = UserDefaults.standard.data(forKey: "LockedLocation") {
                return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedLocation) as? CLLocation
            } else {
                return nil
            }
        } set {
            if let location = newValue {
                if let encodedLocation = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
                    UserDefaults.standard.set(encodedLocation, forKey: "LockedLocation")
                    locationLockedDate = Date()
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "LockedLocation")
                locationLockedDate = nil
            }
        }
    }
    
    static var hasBeenAskedToSaveImages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasBeenAskedToSaveImages")
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasBeenAskedToSaveImages")
        }
    }
    
    static var saveImages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "saveImages")
        } set {
            UserDefaults.standard.set(newValue, forKey: "saveImages")
        }
    }
    
    
    /// Wether the user would like to recieve position reminders, toggleable in settings.
    static var shouldShowPositionReminderToggle: Bool {
        get {
            return UserDefaults.standard.object(forKey: "shouldShowPositionReminderToggle") != nil ? UserDefaults.standard.bool(forKey: "shouldShowPositionReminderToggle"): true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldShowPositionReminderToggle")
        }
    }
    
    /// Keeps track of how many sent observations it has been since user was last reminded about precision importance
    private static var positionReminderObservationCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "positionReminderObservationCount")
        } set {
            UserDefaults.standard.set(newValue, forKey: "positionReminderObservationCount")
        }
    }
    
    static func decreasePositionReminderCounter() {
        positionReminderObservationCount = positionReminderObservationCount - 1
    }
    
    static var shouldShowPositionReminder: Bool {
        return shouldShowPositionReminderToggle ? positionReminderObservationCount <= 0: false
    }
    
    static func setHasShownPositionReminder() {
        UserDefaults.standard.set(20, forKey: "positionReminderObservationCount")
    }
    
    static var hasAcceptedmagePredictionTerms: Bool {
        return UserDefaults.standard.bool(forKey: "hasAcceptedImagePredictionTerms")
    }
    
    static func databaseWasUpdated() {
        UserDefaults.standard.set(Date(), forKey: "databaseLastUpdatedDate")
    }
    
    static func setDefaultSubstrateID(_ id: Int) {
        UserDefaults.standard.set(id, forKey: "defaultSubstrateID")
    }
    
    static func setDefaultVegetationTypeID(_ id: Int) {
        UserDefaults.standard.set(id, forKey: "defaultVegetationTypeID")
    }
    
    static func setDefaultHosts(hosts: [Host]) {
        let ids = hosts.compactMap({$0.id})
        UserDefaults.standard.set(ids, forKey: "defaultHostsIDS")
    }
    
    static func setHasAcceptedImagePredictionTerms(_ accepted: Bool) {
        UserDefaults.standard.set(accepted, forKey: "hasAcceptedImagePredictionTerms")
    }
    
    static func setSaveImages(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "")
    }
    
    static func removeImageName(forUrl url: String) {
        guard var dict = UserDefaults.standard.dictionary(forKey: "fileManagerDict") else {return}
        dict.removeValue(forKey: url)
        UserDefaults.standard.set(dict, forKey: "fileManagerDict")
    }
        
    static func saveImageName(forUrl url: String, imageName: String) {
        if var dict = UserDefaults.standard.dictionary(forKey: "fileManagerDict") {
            dict[url] = imageName
            UserDefaults.standard.set(dict, forKey: "fileManagerDict")
        } else {
            UserDefaults.standard.set([url: imageName], forKey: "fileManagerDict")
        }
    }
    
    static func getImageName(forUrl url: String) -> String? {
        guard let dict = UserDefaults.standard.dictionary(forKey: "fileManagerDict") else {return nil}
        guard let url = dict[url] as? String else {return nil}
        return url
    }
    
    static func setHasSeenImageDeletionTip() {
        UserDefaults.standard.set(true, forKey: "hasSeenImageDeletionTip")
    }
    
    static func hasSeenImageDeletionTip() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenImageDeletionTip")
    }

}
