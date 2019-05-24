//
//  Array+MergeElements.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension Array where Element : Equatable {
    public func returnOriginalElements<C : Collection>(newElements: C) -> [Element] where C.Iterator.Element == Element {
        return newElements.filter({!self.contains($0)})
    }
    
}

extension UIAlertController {
    convenience init(title: String, message: String) {
        self.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    }
}
