//
//  ELFileManager.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/02/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

struct ELFileManager {
    
    enum ELFileManagerError: AppError {
        var errorDescription: String {
            switch self {
            case .imageSavingError: return "Der skete en fejl i forbindelse med at gemme billedet til telefonens midlertidige lagerplads."
            }
        }
        
        var errorTitle: String {
            switch self {
            case .imageSavingError: return "Gemme fejl"
            }
        }
        
        var recoveryAction: RecoveryAction? {
            switch self {
            case .imageSavingError: return .tryAgain
            }
        }
        
        
        case imageSavingError
        
    }
    
    
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
    
    static func saveTempImage(imageData: Data) -> Result<URL, ELFileManagerError> {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(ProcessInfo().globallyUniqueString)
        do {
            try imageData.write(to: temporaryDirectory, options: .atomic)
            return Result.Success(temporaryDirectory)
        } catch {
            return Result.Error(.imageSavingError)
        }
    }
    
    static func deleteImage(imageURL: URL) {
        try? FileManager.default.removeItem(at: imageURL)
    }
    
    fileprivate static func DocumentsDir() -> URL {
          return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
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





