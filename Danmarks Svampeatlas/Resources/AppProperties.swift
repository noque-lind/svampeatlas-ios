//
//  AppProperties.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

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
       return #colorLiteral(red: 0.2823529412, green: 0.368627451, blue: 0.4117647059, alpha: 1)
    }

    class func appThird() -> UIColor {
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
    class func appTitle(customSize size: CGFloat = 20) -> UIFont {
        return UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont(name: "AvenirNext-Regular", size: size)!)
    }
    
    class func appPrimary(customSize size: CGFloat = 15) -> UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "AvenirNext-Regular", size: size)!)
    }
    
    class func appPrimaryHightlighed(customSize size: CGFloat = 15) -> UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "AvenirNext-Medium", size: size)!)
    }
    
    class func appMuted(customSize size: CGFloat = 9) -> UIFont {
        return UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont(name: "AvenirNext-UltraLight", size: size)!)
    }
    
    class func appDivider() -> UIFont {
        return UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont(name: "CaviarDreams-Bold", size: 15)!)
    }
    
    private func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        // create a new font descriptor with the given traits
        if let fd = fontDescriptor.withSymbolicTraits(traits) {
            // return a new  font with the created font descriptor
            return UIFont(descriptor: fd, size: pointSize)
        }
        
        // the given traits couldn't be applied, return self
        return self
    }
    
    func italized() -> UIFont {
        if self === UIFont.appPrimaryHightlighed() {
            return UIFont(name: "AvenirNext-MediumItalic", size: pointSize)!
        } else if self === UIFont.appPrimary() {
            return UIFont(name: "AvenirNext-Italic", size: pointSize)!
        } else if self == UIFont.appTitle() {
            return UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont(name: "AvenirNext-Italic", size: pointSize)!)
        } else {
            return self
        }
    }
    
    
    
    class func appBold() -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: 12)!
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
        return 0.3
    }
}

extension CGFloat {
    static func cornerRadius() -> CGFloat {
        return 8
    }
}

extension CGSize {
    static func shadowOffset() -> CGSize {
        return CGSize(width: 0.0, height: 2.0)
    }
}

extension ELNotificationView {
    static func appNotification(style: ELNotificationView.Style, primaryText: String, secondaryText: String, location: ELNotificationView.Location) -> ELNotificationView {
        return ELNotificationView(style: style, attributes: .appAttributes(), primaryText: primaryText, secondaryText: secondaryText, location: location)
    }
    
    static func appNotification(style: ELNotificationView.Style, location: ELNotificationView.Location) -> ELNotificationView {
        return ELNotificationView.init(style: style, attributes: ELNotificationView.Attributes.appAttributes())
    }
}

extension ELNotificationView.Attributes {
    static func appAttributes() -> ELNotificationView.Attributes {
        return ELNotificationView.Attributes(font: UIFont.appPrimaryHightlighed(), textColor: UIColor.appWhite())
    }
}
