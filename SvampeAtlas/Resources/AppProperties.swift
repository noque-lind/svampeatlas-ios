//
//  AppProperties.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIColor {
   class func appWhite() -> UIColor {
        return #colorLiteral(red: 0.9137254902, green: 0.9254901961, blue: 0.9333333333, alpha: 1)
    }
    
    class func appFontColour() -> UIColor {
        return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    class func appPrimaryColour() -> UIColor {
        return #colorLiteral(red: 0.2156862745, green: 0.2784313725, blue: 0.3098039216, alpha: 1)
    }
    
    class func appSecondaryColour() -> UIColor {
       return #colorLiteral(red: 0.3772668242, green: 0.4889609814, blue: 0.5432303548, alpha: 1)
    }

    class func appThirdColour() -> UIColor {
       return #colorLiteral(red: 1, green: 0.2509803922, blue: 0.5058823529, alpha: 1)
    }
    
    class func appGreen() -> UIColor {
       return #colorLiteral(red: 0, green: 0.6509803922, blue: 0.462745098, alpha: 1)
    }
    
    class func appRed() -> UIColor {
      return  #colorLiteral(red: 0.5764705882, green: 0.1215686275, blue: 0.1137254902, alpha: 1)
    }
    
    class func appYellow() -> UIColor {
      return  #colorLiteral(red: 1, green: 0.6509803922, blue: 0.1882352941, alpha: 1)
    }
    
}

extension UIFont {
    class func appHeader(customSize size: CGFloat = 20) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    
    class func appHeaderDetails(customSize size: CGFloat = 14) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
    
    class func appPrimary(customSize size: CGFloat = 12) -> UIFont {
        return UIFont(name: "AvenirNext-UltraLight", size: size)!
    }
    
    class func appPrimaryHightlighed(customSize size: CGFloat = 12) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
    
    class func appBold() -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: 12)!
    }
    
    
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

extension Float {
    static func shadowOpacity() -> Float {
        return 0.4
    }
}

extension CGFloat {
    static func cornerRadius() -> CGFloat {
        return 2
    }
}
