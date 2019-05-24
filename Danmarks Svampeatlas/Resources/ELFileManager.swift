//
//  ELFileManager.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/02/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

struct ELFileManager {
    
    fileprivate static func getImageName(forImageWithOriginalURL originalURL: String) -> String? {
        guard let dict = UserDefaults.standard.dictionary(forKey: "fileManagerDict"), let name = dict[originalURL] as? String else {return nil}
        return name
    }
    
    fileprivate static func storeOriginalURL(originalURL: String, for imageName: String) {
        if var dict = UserDefaults.standard.dictionary(forKey: "fileManagerDict") {
            dict[originalURL] = imageName
            UserDefaults.standard.set(dict, forKey: "fileManagerDict")
        } else {
            UserDefaults.standard.set([originalURL: imageName], forKey: "fileManagerDict")
        }
    }
    
    fileprivate static func DocumentsDir() -> URL {
          return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    }
    
    static func fileExists(withURL url: String) -> Bool {
        guard let imageName = getImageName(forImageWithOriginalURL: url) else {return false}
        return FileManager.default.fileExists(atPath: DocumentsDir().appendingPathComponent(imageName).absoluteString)
    }
    
    static func saveImage(image: UIImage, url: String) {
        
        let imageName = UUID().uuidString + ".png"
        storeOriginalURL(originalURL: url, for: imageName)
    
        let data = image.pngData()
    
        
        do {
            try data!.write(to: DocumentsDir().appendingPathComponent(imageName))
        } catch {
            debugPrint(error)
        }
    }
    
    static func getImage(withURL url: String) -> UIImage? {
        guard let imageName = getImageName(forImageWithOriginalURL: url) else {return nil}
        
        do {
            let data = try Data(contentsOf: DocumentsDir().appendingPathComponent(imageName))
            guard let image = UIImage(data: data) else {return nil}
            return image
        } catch {
            debugPrint(error)
        }
       return nil
    }
}





