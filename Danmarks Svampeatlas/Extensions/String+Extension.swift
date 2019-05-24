//
//  String+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension String {
    func capitalizeFirst() -> String {
        return String(self.prefix(1).uppercased() + self.dropFirst())
    }
    
    func italized(font: UIFont) -> NSMutableAttributedString {
        let s = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: font.italized()])
        return s
    }
    
    func highlighted() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed()])
    }
    
    func normal() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: UIFont.appPrimary()])
    }
}
