//
//  UIImage+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else {return nil}
        self.init(data: data)
    }
    
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

    func jpegData(sizeInMB: Double, deltaMB: Double = 0.2) -> Data? {
        let allowedSizeInBytes = Int(sizeInMB * 1024 * 1024)
        let deltaInBytes = Int(deltaMB * 1024 * 1024)
        
        var left: CGFloat = 0.0
        var right: CGFloat
        
        if sizeInMB < 0.5 {
            right = 0.50
        } else {
            right = 1.0
        }
        
            var mid = (left + right) / 2.0
            var index = 0
            
            guard var newResImage = self.jpegData(compressionQuality: mid) else {return nil}
            
            while index < 7 {
                index += 1
                
                if newResImage.count < (allowedSizeInBytes - deltaInBytes) {
                    left = mid
                } else if newResImage.count > (allowedSizeInBytes + deltaInBytes) {
                    right = mid
                } else {
                    debugPrint("Compression ran: \(index) times")
                    return newResImage
                }
                
                mid = (left + right) / 2
                guard let newest = self.jpegData(compressionQuality: mid) else {return newResImage}
                newResImage = newest
            }
            
            debugPrint("Compression ran to many times")
            return newResImage
    }
    
    func toBase64() -> String? {
        guard let imageData = self.jpegData(sizeInMB: 0.3) else { return nil }
        debugPrint(imageData.count)
        let base = imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        return base
    }
    
    func rotate() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
                    return self
                }
        
                UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
                self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    return normalizedImage
                } else {
                    return self
                }
    }
}

import ImageIO

extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }

}
