//
//  UINavigationController+AppConfiguration.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 16/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UINavigationController {
    func appConfiguration(translucent: Bool) {
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor.appWhite()
    
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            translucent ? appearance.configureWithTransparentBackground(): appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = translucent ? .clear: .appPrimaryColour()
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = nil
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.isTranslucent = translucent
            navigationBar.barTintColor = UIColor.appPrimaryColour()
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
        }
    }
}
