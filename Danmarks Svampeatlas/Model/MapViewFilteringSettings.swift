//
//  MapViewFilteringSettings.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 07/05/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import CoreGraphics

class MapViewFilteringSettings {
    
    /// In meters
    var distance: CGFloat = 1000
    
    /// In years
    var age: Int = 1
    
    init(distance: CGFloat, age: Int) {
        self.distance = distance
        self.age = age
    }
    
    var distanceText: NSAttributedString {
        let roundedDistance = Double(CGFloat(distance / 1000).rounded(toPlaces: 1))
        let text = "Radius: ".normal()
        text.append("\(roundedDistance)".highlighted())
        text.append(" km.".normal())
        return text
    }
    
    var ageText: NSAttributedString {
        let pronoun = age < 2 ? "år": "år"
        let text = "Fundets alder: ".normal()
        text.append("\(age) \(pronoun)".highlighted())
        return text
    }
}
