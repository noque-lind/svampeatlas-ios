//
//  URL+ExtractExif.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 13/11/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import CoreLocation

extension URL {
    func getExifLocation() -> CLLocation? {
        guard let imageSource = CGImageSourceCreateWithURL(self as CFURL, nil) else {return nil}
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else { return nil }
        guard let gpsDict = imageProperties[String(kCGImagePropertyGPSDictionary)] as? [String: Any] else { return nil }
        guard var latitude = gpsDict[String(kCGImagePropertyGPSLatitude)] as? Double, var longitude = gpsDict[String(kCGImagePropertyGPSLongitude)] as? Double else {return nil}
        let accuracy = ((gpsDict[String(kCGImagePropertyGPSHPositioningError)] as? Double) ?? (gpsDict[String(kCGImagePropertyGPSDOP)] as? Double)) ?? -1
        let altitude = (gpsDict[String(kCGImagePropertyGPSAltitude)] as? Double) ?? 0
        let latitudeRef = (gpsDict[String(kCGImagePropertyGPSLatitudeRef)] as? String)
        let longitudeRef = (gpsDict[String(kCGImagePropertyGPSLongitudeRef)] as? String)
        
        var timeStamp: Date?
        if let exif = (imageProperties[String(kCGImagePropertyExifDictionary)] as? [String: Any]), let timeStampDate = (exif[String(kCGImagePropertyExifDateTimeOriginal)] as? String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current
            timeStamp = dateFormatter.date(from: timeStampDate)
        }
        if latitudeRef == "S" {
            latitude = -latitude
        }
        
        if longitudeRef == "W" {
            longitude = -longitude
        }
        
        return CLLocation.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: accuracy, verticalAccuracy: accuracy, timestamp: timeStamp ?? Date())
    }
}
