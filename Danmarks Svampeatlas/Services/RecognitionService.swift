//
//  RecognitionService.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 10/10/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import ELKit
import LogRocket

class RecognitionService {
    
    enum MyError: AppError {
        var recoveryAction: RecoveryAction? {
            return nil
        }
    
        case errorAddingData
        case notInitialized
        case errorFetchingResults
        case unknown
    

        var message: String {
            switch self {
            case .errorAddingData: return NSLocalizedString("recognitionServiceError_addingDataError_message", comment: "")
            case .notInitialized: return ""
            case .errorFetchingResults: return NSLocalizedString("recognitionServiceError_addingFetchingResults_message", comment: "")
            case .unknown: return ""
            }
        }

        var title: String {
            switch self {
            default: return NSLocalizedString("recognitionServiceError_title", comment: "")
            }
        }
    }
    
    struct AddPhotoRequestResult: Decodable {
        let observationId: String
        
        private enum CodingKeys: String, CodingKey {
            case observationId = "observation_id"
        }
    }
    
    struct GetResultsRequestResult: Decodable {
        var taxonIds = [Int]()
        var conf = [Double]()
        var reliablePrediction: Bool? = false
        
        private enum CodingKeys: String, CodingKey {
            case taxonIds = "taxon_ids"
            case conf
            case reliablePrediction = "reliable_preds"
        }
    }
    
    private var currentRequest: Task<String, Error>?
    
    func addImage(imageURL: URL) async {
        do {
            if currentRequest == nil {
                currentRequest = Task<String, Error>(priority: .background) {
                    return try await performAddImage(imageURL: imageURL)
                }
            } else {
                if let currentTask = currentRequest {
                    let id = try await currentTask.value
                    self.currentRequest = Task(priority: .background, operation: {
                        return try await performAddImage(id: id, imageURL: imageURL)
                    })
                }
            }
        } catch {
            Logger.error(message: "Error adding image to request " + error.localizedDescription)
        }
    }
    
    func addMetadata(substrate: Substrate, vegetationType: VegetationType, date: Date) async {
        do {
            guard let id = try await currentRequest?.value else {throw MyError.notInitialized}
            let data = try JSONSerialization.data(withJSONObject: ["habitat": String(vegetationType.id), "substrate": String(substrate.id), "month": date.get(.month)], options: [])
            currentRequest = Task.init(priority: .userInitiated, operation: {
                return try await performAddMetadata(id: id, data: data)
            })
        } catch {
            Logger.error(message: "Error adding metadata to request " + error.localizedDescription)
        }
    }
    
    func getResults() async -> Result<GetResultsRequestResult, AppError> {
        guard let currentRequest = currentRequest else {return Result.failure(MyError.notInitialized)}
            switch await currentRequest.result {
            case .success(let id):
                do {
                    var result = GetResultsRequestResult(taxonIds: [], conf: [])
                    while result.taxonIds.isEmpty {
                        result = try await performGetResults(id: id)
                        if result.taxonIds.isEmpty {
                            try await  Task.sleep(nanoseconds: 1_000_000_000)
                            
                        }
                    }
                    return Result.success(result)
                } catch let error as AppError {
                    Logger.error(message: error.localizedDescription)
                    return Result.failure(error)
                } catch {
                    Logger.error(message: error.localizedDescription)
                    return .failure(MyError.unknown)
                }
            case .failure(let error):
                Logger.error(message: error.localizedDescription)
                return Result.failure(MyError.errorAddingData)
            }
       }
    
    func reset() {
        currentRequest?.cancel()
        currentRequest = nil
    }
    
    private func performAddMetadata(id: String, data: Data) async throws -> String {
        switch await DataService.instance.createDataTaskRequestAsync(url: API.Post.ImagePredictionAddMetadata(id: id).encodedURL, method: "POST", data: data) {
        case .failure(let error):
            throw error
        case .success(let data):
            let result = try JSONDecoder().decode(AddPhotoRequestResult.self, from: data)
            return result.observationId
        }
    }

  
    
    private func performAddImage(id: String? = nil, imageURL: URL) async throws -> String {
        guard let media = ELMultipartFormData.Media(withImage: imageURL, forKey: "image") else { throw DataService.DataServiceError.encodingError }
        let boundary = "apiclient\(Date.timeIntervalSinceReferenceDate)"
        let data = ELMultipartFormData.createDataBody(withParameters: nil, media: media, boundary: boundary)
        switch await DataService.instance.createDataTaskRequestAsync(url: API.Post.ImagePredictionAddPhoto(id: id).encodedURL, method: "POST", data: data, contentType: "multipart/form-data; boundary=\(boundary)", contentLenght: nil, token: nil, largeDownload: false) {
        case .failure(let error):
            throw error
        case .success(let data):
            let result = try JSONDecoder().decode(AddPhotoRequestResult.self, from: data)
            return result.observationId
        }
        
    }
    
    private func performGetResults(id: String) async throws -> GetResultsRequestResult {
        switch await DataService.instance.createDataTaskRequestAsync(url: API.Request.ImagePredictionGetResults(id: id).encodedURL) {
        case .success(let data):
            let some = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            return try JSONDecoder().decode(GetResultsRequestResult.self, from: data)
        case .failure(let error):
            throw error
        }
    }
}
