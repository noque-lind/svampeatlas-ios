//
//  NavigationItem.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 14/03/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum NavigationItem {
    
    case loginVC
    case myPageVC
    case newObservationVC
    case nearbyVC
    case mushroomsVC
    case cameraVC
    
    
    var title: String {
        switch self {
        case .loginVC:
            return "Login"
        case .myPageVC:
            return "Min side"
        case .newObservationVC:
            return "Nyt fund"
        case .nearbyVC:
            return "I nærheden"
        case .mushroomsVC:
            return "Svampebog"
        case .cameraVC:
            return "Artsbestemmelse"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .loginVC:
            return #imageLiteral(resourceName: "Icons_Login")
        case .myPageVC:
            return #imageLiteral(resourceName: "Icons_Profile")
        case .newObservationVC:
            return #imageLiteral(resourceName: "Plus")
        case .nearbyVC:
            return #imageLiteral(resourceName: "Icons_Location")
        case .mushroomsVC:
            return #imageLiteral(resourceName: "Book")
        case .cameraVC:
            return #imageLiteral(resourceName: "Camera")
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .cameraVC:
            return false
        default:
            return true
        }
    }
    
}
