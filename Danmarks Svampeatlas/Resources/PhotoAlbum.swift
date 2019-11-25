//
//  PhotoAlbum.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 14/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Photos

class Album {
    
    private let name: String
    
    init (name: String) {
        self.name = name
    }
    
    func dfdf() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Svampeatlas")
        }) { (success, error) in
//            if succes {
//                
//            }
        }
        
        
    }
    
    func fetch() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title =%@", "Svampeatlas")
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        collection.firstObject
    }
}
