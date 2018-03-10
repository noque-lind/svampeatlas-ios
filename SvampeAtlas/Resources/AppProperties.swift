//
//  AppProperties.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIColor {
    class func appDarkBlue() -> UIColor {
       return #colorLiteral(red: 0.2142155468, green: 0.2800558805, blue: 0.3091996908, alpha: 1)
    }
    
    class func appLightBlue() -> UIColor {
       return #colorLiteral(red: 0.3772668242, green: 0.4889609814, blue: 0.5432303548, alpha: 1)
    }
    
    class func appWhite() -> UIColor {
        return #colorLiteral(red: 0.9137254902, green: 0.9254901961, blue: 0.9333333333, alpha: 1)
    }
    
    class func appFontColour() -> UIColor {
        return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    class func appPrimaryColour() -> UIColor {
        return #colorLiteral(red: 0.2142155468, green: 0.2800558805, blue: 0.3091996908, alpha: 1)
    }
    
    class func appSecondaryColour() -> UIColor {
       return #colorLiteral(red: 0.3772668242, green: 0.4889609814, blue: 0.5432303548, alpha: 1)
    }

    class func appThirdColour() -> UIColor {
       return #colorLiteral(red: 1, green: 0.2509803922, blue: 0.5058823529, alpha: 1)
    }
    
}

extension UIFont {
    class func appTitle(customSize size: CGFloat = 20) -> UIFont {
        return UIFont(name: "AvenirNext-DemiBold", size: size)!
    }
    
    class func appText(customSize size: CGFloat = 13) -> UIFont {
        return UIFont(name: "AvenirNext-UltraLight", size: size)!
    }
    
    class func appTextHighlight(customSize size: CGFloat = 13) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
}
