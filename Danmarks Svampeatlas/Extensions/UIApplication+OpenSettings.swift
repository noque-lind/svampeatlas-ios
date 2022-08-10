//
//  UIApplication+OpenSettings.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 24/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIApplication {
    static func openSettings() {
        if let bundleID = Bundle.main.bundleIdentifier, let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleID)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
