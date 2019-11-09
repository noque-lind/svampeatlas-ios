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
    case facebook
    case about
    
    
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
            return "Navneforslag"

            case .facebook:
                return "Facebook"
        case .about:
            return "Om"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .loginVC:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Login")
        case .myPageVC:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Profile")
        case .newObservationVC:
            return #imageLiteral(resourceName: "Icons_Icons_Add")
        case .nearbyVC:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Location")
        case .mushroomsVC:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Book")
        case .cameraVC:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Camera")
        case .facebook:
            return #imageLiteral(resourceName: "Icons_MenuIcons_Facebook")
        case .about:
            return #imageLiteral(resourceName: "Icons_MenuIcons_About")
        }
    }
    
    var isEnabled: Bool {
        switch self {

        default:
            return true
        }
    }
    
    var rightTitle: String? {
        switch self {
        case .cameraVC:
            return "BETA"
        default:
            return nil
        }
    }
    
}
