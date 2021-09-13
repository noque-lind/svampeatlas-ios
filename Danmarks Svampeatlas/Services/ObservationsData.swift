//
//  ObservationsData.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class ObservationsData {
    
    private let ds: DataService
    
    
    init(ds: DataService) {
        self.ds = ds
    }
    
    func postObservation(userObservation: UserObservation, session: Session, token: String, completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
        guard let dict = userObservation.returnAsDictionary(session: session, isEdit: false) else {completion(.failure(DataService.DataServiceError.unhandled)); return}
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            ds.createDataTaskRequest(url: API.postObservationURL(), method: "POST", data: data, contentType: "application/json", token: token) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    guard let dict = json as? Dictionary<String, Any> else {return}
                    
                    let observationID = (dict["_id"] as? Int)!
                    
                    self.uploadImages(observationID: observationID, imageURLs: userObservation.images.map({$0.url}), token: token, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            completion(Result.failure(error))
                        case .success(let uploadedCount):
                            completion(Result.success((observationID: observationID, uploadedImagesCount: uploadedCount)))
                        }
                    })
                }
            }
            
        } catch {
            debugPrint(error)
        }
    }
    
    func editObservation(withId id: Int, userObservation: UserObservation, session: Session, token: String, completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
        guard let dict = userObservation.returnAsDictionary(session: session, isEdit: false) else {completion(.failure(DataService.DataServiceError.unhandled)); return}
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            ds.createDataTaskRequest(url: API.Put.observation(id: id).encodedURL, method: "PUT", data: data, contentType: "application/json", token: token) { (result) in
                
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    guard let dict = json as? Dictionary<String, Any> else {return}
                    
                    let observationID = (dict["_id"] as? Int)!
                    let userImages: [UserObservation.Image] = userObservation.images.compactMap({
                        guard case .new = $0.type else {return nil}
                        return $0
                    })
                    self.uploadImages(observationID: observationID, imageURLs: userImages.map({$0.url}), token: token, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            completion(Result.failure(error))
                        case .success(let uploadedCount):
                            completion(Result.success((observationID: observationID, uploadedImagesCount: uploadedCount)))
                        }
                    })
                }
            }
            
        } catch {
            debugPrint(error)
        }
    }
    
   
    
    func deleteObservation(id: Int, token: String, completion: @escaping (Result<Void, AppError>) -> ()) {
        ds.createDataTaskRequest(url: API.Delete.observation(id: id).encodedURL, method: "DELETE", data: nil, contentType: nil, contentLenght: nil, token: token) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    private func uploadImages(observationID: Int, imageURLs: [URL], token: String, completion: @escaping (Result<Int, AppError>) -> ()) {
                   
        let dispatchGroup = DispatchGroup()
        var uploadedCount = 0
        
        for imageURL in imageURLs {
            dispatchGroup.enter()
            
            uploadImage(observationID: observationID, imageURL: imageURL, token: token) { (result) in
                switch result {
                case .failure(let error):
                    debugPrint(error)
                case .success(_):
                    uploadedCount += 1
                }
            
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            completion(Result.success(uploadedCount))
        }
    }
    
    func deleteImage(id: Int, token: String, completion:@escaping (Result<Void, AppError>) -> ()) {
        ds.createDataTaskRequest(url: API.Delete.image(id: id).encodedURL, method: "DELETE", data: nil, contentType: nil, contentLenght: nil, token: token) { (result) in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success: completion(.success(()))
            }
        }
    }
    
    private func uploadImage(observationID: Int, imageURL: URL, token: String, completion: @escaping (Result<Void, AppError>) -> ()) {
       
        guard let media = ELMultipartFormData.Media(withImage: imageURL, forKey: "file") else {completion(Result.failure(DataService.DataServiceError.encodingError)); return}
        
        let boundary = "apiclient\(Date.timeIntervalSinceReferenceDate)"
        let data = ELMultipartFormData.createDataBody(withParameters: nil, media: media, boundary: boundary)
        
        ds.createDataTaskRequest(url: API.postImageURL(observationID: observationID), method: "POST", data: data, contentType: "multipart/form-data; boundary=\(boundary)", contentLenght: nil, token: token) { (result) in
            switch result {
            case .failure(let error):
                print(error)
                completion(Result.failure(error))
            case .success(_):
                completion(Result.success(()))
            }
        }
    }
    
    
}
