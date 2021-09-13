//
//  OfflineDownloaderViewModel.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 31/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import ELKit

class DownloaderviewModel: NSObject {
    
    enum State {
        case Loading(message: String)
        case Completed
        case Error(error: AppError)
    }
    
    private let _state = ELListener<State?>.init(nil)
    lazy var state = ELListenerImmutable(_state)
    
    override init() {
        super.init()
        fetch()
    }
    
    
    private func fetch() {
  
        
        _state.set(.Loading(message: NSLocalizedString("Downloading taxons", comment: "")))
        
        
        DataService.instance.getMushrooms(searchString: nil, speciesQueries: [.images(required: false), .danishNames], limit: nil, offset: 0, largeDownload: true, useCache: false) { [weak self] result in
            switch result {
            case .success(let mushrooms):
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                self?._state.set(.Loading(message: NSLocalizedString("Downloading metadata", comment: "")))
                DataService.instance.downloadSubstrateGroups(completion: { result in
                    dispatchGroup.leave()
                })
                
                dispatchGroup.enter()
                DataService.instance.downloadVegetationTypes() { result in
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                    self?.saveToDatabase(mushrooms: mushrooms)

                }
            case .failure(let error):
                self?._state.set(.Error(error: error))
            }
        }
    }
    
    private func saveToDatabase(mushrooms: [Mushroom]) {
        _state.set(.Loading(message: NSLocalizedString("Saving to local storage", comment: "")))
        Database.instance.mushroomsRepository.save(items: mushrooms) { [weak self] result in
            switch result {
            case .success(): self?._state.set(.Completed);  UserDefaultsHelper.lastDataUpdateDate = Date()
            case .failure(let error):
                self?._state.set(.Error(error: error))
            }
        }
    }
}
