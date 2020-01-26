//
//  ELPhotos.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 24/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import Photos

protocol ELPhotosManagerDelegate: NavigationDelegate {
    func error(_ error: ELPhotos.ELPhotosError)
    func assetFetched(_ imageURL: URL)
    func assetFetchCanceled()
}

class ELPhotos: NSObject  {
    
    enum ELPhotosError: AppError {
        var errorDescription: String {
            switch self {
            case .notAuthorized: return NSLocalizedString("elPhotosError_notAuthorized_message", comment: "")
            case .unknownSaveError: return NSLocalizedString("elPhotosError_unknownSaveError_message", comment: "")
            case .unknownFetchError: return NSLocalizedString("elPhotosError_unknownFetchError_message", comment: "")
            }
        }
        
        var errorTitle: String {
            switch self {
            case .notAuthorized: return NSLocalizedString("elPhotosError_notAuthorized_title", comment: "")
            case .unknownSaveError: return NSLocalizedString("elPhotosError_unknownSaveError_title", comment: "")
            case .unknownFetchError: return NSLocalizedString("elPhotosError_unknownFetchError_title", comment: "")
            }
        }
        
        var recoveryAction: RecoveryAction? {
            switch self {
            case .notAuthorized: return .openSettings
            case .unknownSaveError: return .tryAgain
            case .unknownFetchError: return .tryAgain
            }
        }
        
        case notAuthorized
        case unknownSaveError
        case unknownFetchError
    }
    
    
    weak var delegate: ELPhotosManagerDelegate?
    private var dispatchQueue = DispatchQueue(label: "ELPhotosManager", qos: .utility)
    
    private var authorizationsStatus: PHAuthorizationStatus {
        get {
            PHPhotoLibrary.authorizationStatus()
        }
    }
    
    static func fetchPhotoLibraryThumbnail(size: CGSize, completion: @escaping (UIImage?) -> ()) {
        switch PHPhotoLibrary.authorizationStatus() {
               case .authorized:
                   let fetchOptions = PHFetchOptions()
                   fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                   fetchOptions.fetchLimit = 1
                   
                   let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                   
                   guard let phAsset = fetchResult.firstObject else {return}
                   let requestOptions = PHImageRequestOptions()
                   requestOptions.isSynchronous = false
                   
                   PHImageManager.default().requestImage(for: phAsset, targetSize: size, contentMode: .aspectFit, options: requestOptions) { (image, _) in
                       guard let image = image else {return}
                        completion(image)
                   }
               case .denied, .restricted, .notDetermined:
                    completion(nil)
               }
    }
    
    func showPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization { [weak delegate, weak self] (authorization) in
            DispatchQueue.main.async {
            switch authorization {
            case .notDetermined, .restricted, .denied:
                    self?.delegate?.error(.notAuthorized)
            case .authorized:
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.modalPresentationStyle = .fullScreen
                    picker.delegate = self
                    delegate?.presentVC(picker)
            }
            }
        }
    }
    
    func saveImage(photoData: Data, inAlbum albumName: String) {
        PHPhotoLibrary.requestAuthorization { [weak delegate, weak self] (authorization) in
            switch authorization {
            case .notDetermined, .restricted, .denied:
                DispatchQueue.main.async {
                    delegate?.error(.notAuthorized)
                }
            case .authorized:
                self?.dispatchQueue.sync {
                    if let album = self?.fetchAlbumWithName(albumName) {
                        self?.saveImageInAlbum(photoData: photoData, album)
                    } else {
                        self?.createAlbumWithName(albumName) { (error) in
                            if let error = error {
                                DispatchQueue.main.async {
                                    debugPrint(error)
                                    delegate?.error(.unknownSaveError)
                                }
                            } else if let album = self?.fetchAlbumWithName(albumName) {
                                self?.saveImageInAlbum(photoData: photoData, album)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveImageInAlbum(photoData: Data, _ album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = PHAssetCreationRequest.forAsset()
            assetCreationRequest.addResource(with: .photo, data: photoData, options: nil)
            if let assetPlaceholder = assetCreationRequest.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration: NSArray = [assetPlaceholder]
                albumChangeRequest?.addAssets(enumeration)
            }
        }, completionHandler: nil)
    }
    
    private func fetchAlbumWithName(_ albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
    }
    
    private func createAlbumWithName(_ albumName: String, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) { (success, error) in
            completion(error)
        }
    }
}

extension ELPhotos: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let phAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {return}
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        PHImageManager.default().requestImageData(for: phAsset, options: requestOptions) { [weak self] (data, string, orientation, nil) in
            if let data = data {
                switch ELFileManager.saveTempImage(imageData: data) {
                case .failure(let error):
                    self?.delegate?.error(.unknownFetchError)
                case .success(let url):
                    self?.delegate?.assetFetched(url)
                }
            } else {
                self?.delegate?.error(.unknownFetchError)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.assetFetchCanceled()
    }
}
