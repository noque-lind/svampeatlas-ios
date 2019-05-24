//
//  CGFloat+Extension.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 07/05/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
