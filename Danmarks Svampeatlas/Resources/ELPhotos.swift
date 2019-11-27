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
    func assetFetched(_ phAsset: PHAsset)
    func assetFetchCanceled()
}




class ELPhotos: NSObject  {
    
    enum ELPhotosError: AppError {
        var errorDescription: String {
            switch self {
            case .notAuthorized: return "Du har ikke givet appen tilladelse til at skrive og læse til dit fotobibliotek. Du kan ændre det i indstillinger, men bemærk at dette genstarter appen."
            case .unknown: return "Der skete en ukendt fejl i forbindelse med at gemme billedet til dit fotoalbum."
            }
        }
        
        var errorTitle: String {
            switch self {
            case .notAuthorized: return "Mangler tilladelse"
            case .unknown: return "Ukendt fejl"
            }
        }
        
        var recoveryAction: RecoveryAction? {
            switch self {
            case .notAuthorized: return .openSettings
            case .unknown: return .tryAgain
            }
        }
        
        case notAuthorized
        case unknown
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
    
    func saveImage(photoData: Data, location: CLLocation?, inAlbum albumName: String) {
        PHPhotoLibrary.requestAuthorization { [weak delegate, weak self] (authorization) in
            switch authorization {
            case .notDetermined, .restricted, .denied:
                DispatchQueue.main.async {
                    delegate?.error(.notAuthorized)
                }
            case .authorized:
                self?.dispatchQueue.sync {
                    if let album = self?.fetchAlbumWithName(albumName) {
                        self?.saveImageInAlbum(photoData: photoData, location: location, album)
                    } else {
                        self?.createAlbumWithName(albumName) { (error) in
                            if let error = error {
                                DispatchQueue.main.async {
                                    debugPrint(error)
                                    delegate?.error(.unknown)
                                }
                            } else if let album = self?.fetchAlbumWithName(albumName) {
                                self?.saveImageInAlbum(photoData: photoData, location: location, album)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveImageInAlbum(photoData: Data, location: CLLocation?, _ album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = PHAssetCreationRequest.forAsset()
            assetCreationRequest.location = location
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
        guard let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {return}
        picker.dismiss(animated: true, completion: nil)
        delegate?.assetFetched(asset)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.assetFetchCanceled()
    }
}
