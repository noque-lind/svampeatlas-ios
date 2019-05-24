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
                debugPrint(Calendar.current.dateComponents([.day], from: databaseLastUpdatedDate).day)
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
}
