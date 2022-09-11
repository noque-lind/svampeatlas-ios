//
//  UIApplication+Versions.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 12/08/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIApplication {
    static func currentVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
