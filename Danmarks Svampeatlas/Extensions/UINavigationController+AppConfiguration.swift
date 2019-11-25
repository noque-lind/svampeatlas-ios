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
        navigationBar.isTranslucent = translucent
        navigationBar.tintColor = UIColor.appWhite()
        navigationBar.barTintColor = UIColor.appPrimaryColour()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}
