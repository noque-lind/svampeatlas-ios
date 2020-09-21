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
    case settings
    case about
    
    
    var title: String {
        switch self {
        case .loginVC:
            return NSLocalizedString("navigationItem_loginVC", comment: "")
        case .myPageVC:
            return NSLocalizedString("navigationItem_myPageVC", comment: "")
        case .newObservationVC:
            return NSLocalizedString("navigationItem_newObservationVC", comment: "")
        case .nearbyVC:
            return NSLocalizedString("navigationItem_nearbyVC", comment: "")
        case .mushroomsVC:
            return NSLocalizedString("navigationItem_mushroomsVC", comment: "")
        case .cameraVC:
            return NSLocalizedString("navigationItem_cameraVC", comment: "")
        case .settings:
            return NSLocalizedString("navigationItem_settings", comment: "")
            case .facebook:
                return NSLocalizedString("navigationItem_facebook", comment: "")
        case .about:
            return NSLocalizedString("navigationItem_about", comment: "")
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
        case .settings:
            return UIImage(named: "Icons_MenuIcons_Settings")!
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
