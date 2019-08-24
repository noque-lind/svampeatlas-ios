//
//  UIImage+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIImage {
    func colorized(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setBlendMode(.multiply)
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(self.cgImage!, in: rect)
            context.clip(to: rect, mask: self.cgImage!)
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return colorizedImage!
    }
    
    ///This function returns the image to JPEG with a compression value that corresponds with the desired size in MB. The returned image size might be either

    func jpegData(sizeInMB: Double, deltaInMB: Double = 0.2) -> Data? {
        let allowedSizeInBytes = Int(sizeInMB * 1024 * 1024)
        let deltaInBytes = Int(deltaInMB * 1024 * 1024)
        
        guard let fullResImage = self.jpegData(compressionQuality: 1.0) else {return nil}
        debugPrint(Int(deltaInBytes + allowedSizeInBytes))
        if fullResImage.count < Int(deltaInBytes + allowedSizeInBytes) {
            return fullResImage
        }
        
        var i = 0
        
        var left:CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        var newResImage = self.jpegData(compressionQuality: mid)
        
        while (true) {
            i += 1
            if (i > 13) {
                debugPrint("Compression ran too many times ") // ideally max should be 7 times as  log(base 2) 100 = 6.6
                break
            }
        
            
            if ((newResImage?.count)! < (allowedSizeInBytes - deltaInBytes)) {
                left = mid
            } else if ((newResImage?.count)! > (allowedSizeInBytes + deltaInBytes)) {
                right = mid
            } else {
                return newResImage!
            }
            mid = (left + right) / 2.0
            newResImage = self.jpegData(compressionQuality: mid)
            
        }
        return self.jpegData(compressionQuality: 0.5)!
    }
}
