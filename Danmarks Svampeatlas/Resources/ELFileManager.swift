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
            case .imageSavingError: return NSLocalizedString("elFileManagerError_imageSavingError_message", comment: "")
            }
        }
        
        var errorTitle: String {
            switch self {
            case .imageSavingError: return NSLocalizedString("elFileManagerError_imageSavingError_title", comment: "")
            }
        }
        
        var recoveryAction: mRecoveryAction? {
            switch self {
            case .imageSavingError: return .tryAgain
            }
        }
    
        case imageSavingError
        
    }
    

    static func saveTempImage(imageData: Data) -> Result<URL, ELFileManagerError> {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(ProcessInfo().globallyUniqueString)
        do {
            try imageData.write(to: temporaryDirectory, options: .atomic)
            return Result.success(temporaryDirectory)
        } catch {
            return Result.failure(.imageSavingError)
        }
    }
    
    static func deleteImage(imageURL url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    fileprivate static func DocumentsDir() -> URL {
          return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    
    
    
    static func mushroomImageExists(withURL url: String) -> Bool {
        guard let imageName = UserDefaultsHelper.getImageName(forUrl: url) else {return false}
        return FileManager.default.fileExists(atPath: DocumentsDir().appendingPathComponent(imageName).absoluteString)
    }
    
    static func saveMushroomImage(image: UIImage, url: String) {
        let imageName = UUID().uuidString + ".png"
        UserDefaultsHelper.saveImageName(forUrl: url, imageName: imageName)
    
        if let data = image.pngData() {
            try? data.write(to: DocumentsDir().appendingPathComponent(imageName))
        }
    }
    
    static func deleteMushroomImage(withUrl url: String) {
        guard let imageName = UserDefaultsHelper.getImageName(forUrl: url) else {return}
        try? FileManager.default.removeItem(at: DocumentsDir().appendingPathComponent(imageName))
        UserDefaultsHelper.removeImageName(forUrl: url)
    }
    
    static func getMushroomImage(withURL url: String) -> UIImage? {
        guard let imageName = UserDefaultsHelper.getImageName(forUrl: url) else {return nil}
        
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





