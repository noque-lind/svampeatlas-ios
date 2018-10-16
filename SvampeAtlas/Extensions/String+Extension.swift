//
//  String+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirst() -> String {
        return String(self.prefix(1).uppercased() + self.dropFirst())
    }
}
