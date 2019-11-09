//
//  UIApplication+Urls.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 13/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                if #available(iOS 10.0, *) {
                    application.open(URL(string: url)!, options: [:], completionHandler: nil)
                }
                else {
                    application.openURL(URL(string: url)!)
                }
                return
            }
        }
    }
}

