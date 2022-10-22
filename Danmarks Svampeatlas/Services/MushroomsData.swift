//
//  MushroomsData.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class MushroomsData {
    private let ds: DataService
    
    init(ds: DataService) {
        self.ds = ds
    }
    
    func fetchMushrooms(from result: RecognitionService.GetResultsRequestResult) async -> [Prediction] {
        var predictions = [Prediction]()
        
        for index in result.taxonIds.indices {
            switch await getMushroom(id: result.taxonIds[index]) {
            case .success(let mushroom):
                predictions.append(.init(mushroom: mushroom, score: result.conf[index]))
            case .failure(_):
            // TODO: HANDLE ERROR
                continue
            }
        }
        return predictions
    }
        
    func getMushroom(id: Int, ignoreLocal: Bool = false) async -> Result<Mushroom, AppError>  {
        if !ignoreLocal, let mushroom = fetchFromRepository(id: id) {
            return Result.success(mushroom)
        } else {
            return await fetch(withID: id)
        }
    }
    
    private func fetchFromRepository(id: Int) -> Mushroom? {
        guard UserDefaultsHelper.offlineDatabasePresent else {return nil}
        if let cdMushroom = Database.instance.mushroomsRepository.fetch(id: id) {
            let mushroom = Mushroom(from: cdMushroom)
            // If mushroom contains a different acceptedTaxon that requested id, fetch the accepted ID
            if let acceptedTaxon = mushroom.acceptedTaxon?.id, acceptedTaxon != id {
                return fetchFromRepository(id: acceptedTaxon)
            } else {
                return mushroom
            }
        }
        return nil
    }
    
   private func fetch(withID id: Int) async ->  Result<Mushroom, AppError> {
        switch await ds.createDataTaskRequestAsync(url: API.Request.Mushroom(id: id).encodedURL) {
            case .failure(let error):
               return Result.failure(error)
            case .success(let data):
                do {
                    guard let mushroom = try JSONDecoder().decode([Mushroom].self, from: data).first else {return Result.failure(DataService.DataServiceError.extractionError) }
                    if let acceptedId = mushroom.acceptedTaxon?.id, acceptedId != id {
                        return await fetch(withID: acceptedId)
                    } else {
                        return Result.success(mushroom)
                    }
                } catch {
                    return Result.failure(DataService.DataServiceError.decodingError(error))
                }
        }
    }
    
}
