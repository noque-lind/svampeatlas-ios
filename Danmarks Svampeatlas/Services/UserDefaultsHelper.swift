//
//  UserDefaultsHelper.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 19/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

struct UserDefaultsHelper {
    static var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        } set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "token")
            } else {
                UserDefaults.standard.set(newValue, forKey: "token")
            }
        }
    }
    
    
    static var shouldUpdateDatabase: Bool {
        get {
            guard let databaseLastUpdatedDate = UserDefaults.standard.object(forKey: "databaseLastUpdatedDate") as? Date else {return true}
            
            if Calendar.current.dateComponents([.day], from: databaseLastUpdatedDate).day ?? 0 < 30 {
                return false
            } else {
                return true
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
    
    static var hasBeenAskedToSaveImages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasBeenAskedToSaveImages")
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasBeenAskedToSaveImages")
        }
    }
    
    static var hasSeenWhatsNew: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenWhatsNew1.5")
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenWhatsNew1.5")
        }
    }
    
    static var saveImages: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "saveImages")
        } set {
            UserDefaults.standard.set(newValue, forKey: "saveImages")
        }
    }
    
    static var lastDataUpdateDate: Date? {
        get {
            let dateString = UserDefaults.standard.double(forKey: "lastDataUpdate")
            if dateString != 0 {
                return Date(timeIntervalSince1970: dateString)
            } else {
                return nil
            }
        } set {
            if let date = newValue {
                UserDefaults.standard.setValue(date.timeIntervalSince1970, forKey: "lastDataUpdate")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastDataUpdate")
            }
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
            print(UserDefaults.standard.integer(forKey: "positionReminderObservationCount"))
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
        UserDefaults.standard.set(5, forKey: "positionReminderObservationCount")
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
