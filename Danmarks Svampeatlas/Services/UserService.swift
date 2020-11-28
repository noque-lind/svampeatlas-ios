//
//  UserService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import UIKit.UIImage
import ELKit



protocol SessionDelegate: class {
    func userUpdated(user: User)
}

class Session {
    
    enum SessionError: AppError {
        var recoveryAction: RecoveryAction? {
            switch self {
            case .notLoggedIn, .tokenInvalid:
                return .login
            default: return nil
            }
        }
        
    
        var message: String {
            switch self {
            case .notLoggedIn:
                return NSLocalizedString("sessionError_notLoggedIn_message", comment: "")
            case .tokenInvalid:
                return  NSLocalizedString("sessionError_tokenInvalid_message", comment: "")
            case .noNotifications:
                return NSLocalizedString("sessionError_noNotifications_message", comment: "")
            case .noObservations:
                return NSLocalizedString("sessionError_noObservations_message", comment: "")
            }
        }
        
        var title: String {
            switch self {
            case .notLoggedIn:
                return NSLocalizedString("sessionError_notLoggedIn_title", comment: "")
            case .tokenInvalid:
                return NSLocalizedString("sessionError_tokenInvalid_title", comment: "")
            case .noNotifications:
                return NSLocalizedString("sessionError_noNotifications_title", comment: "")
            case .noObservations:
                return NSLocalizedString("sessionError_noObservations_title", comment: "")
            }
        }
        
        case notLoggedIn
        case tokenInvalid
        case noNotifications
        case noObservations
    }

    private var token: String
    public private(set) var user: User
    
    private init(token: String, user: User) {
        self.token = token
        self.user = user
        DataService.instance.sessionDelegate = self
    }
    
    func logout() {
        CoreDataHelper.deleteUser()
        UserDefaultsHelper.token = nil
    }
    
    func getNotificationCount(completion: @escaping (Result<Int, AppError>) -> ()) {
        DataService.instance.getUserNotificationCount(token: token) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let count):
                completion(Result.success(count))
            }
        }
    }
    
    func getObservationsCount(completion: @escaping (Result<Int, AppError>) -> ()) {
        DataService.instance.getUserObservationsCount(userID: user.id) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let count):
                completion(Result.success(count))
            }
        }
    }
    
    func getUserNotifications(limit: Int, offset: Int, completion: @escaping (Result<[UserNotification], AppError>) -> ()) {
        DataService.instance.getNotifications(userID: user.id, token: token, limit: limit, offset: offset) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let userNotifications):
                guard userNotifications.count != 0 else {completion(Result.failure(SessionError.noNotifications)); return}
                completion(Result.success(userNotifications))
            }
        }
    }
    
    func getObservations(limit: Int, offset: Int, completion: @escaping (Result<[Observation], AppError>) -> ()) {
        DataService.instance.downloadUserObservations(limit: limit, offset: offset, userID: user.id) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let observations):
                guard observations.count != 0 else {completion(Result.failure(SessionError.noObservations)); return}
                completion(Result.success(observations))
            }
        }
    }
    
    func uploadComment(observationID: Int, comment: String, completion: @escaping (Result<Comment, AppError>) -> ()) {
        DataService.instance.postComment(taxonID: observationID, comment: comment, token: token, completion: completion)
    }
    
    func uploadObservation(dict: [String: Any], imageURLs: [URL], completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
        DataService.instance.postObservation(dict: dict, imageURLs: imageURLs, token: token, completion: completion)
    }
    
    func editObservation(id: Int, dict: [String: Any], newImageURLs: [URL], completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
        DataService.instance.editObservation(withId: id, dict: dict, newImageURLs: newImageURLs, token: token, completion: completion)
    }
    
    func deleteObservation(id: Int, completion: @escaping (Result<Void, AppError>) -> ()) {
        DataService.instance.deleteObservation(id: id, token: token, completion: completion)
    }
    
    func reportOffensiveContent(observationID: Int, comment: String?, completion: @escaping () -> ()) {
        DataService.instance.postOffensiveContentComment(observationID: observationID, comment: comment, token: token, completion: completion)
    }
    
    func markNotificationAsRead(notificationID: Int) {
        DataService.instance.markNotificationAsRead(notificationID: notificationID, token: token)
    }
    
    func deleteImage(id: Int, completion:  @escaping (Result<Void, AppError>) -> ()) {
        DataService.instance.deleteImage(id: id, token: token, completion: completion)
    }
}

//MARK: Static functions
extension Session {
    static func resumeSession(completion: @escaping (Result<Session, AppError>) -> ()) {
        guard let token = UserDefaultsHelper.token else {completion(Result.failure(SessionError.notLoggedIn)); return}
        getUser(token: token) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let user):
                completion(Result.success(Session(token: token, user: user)))
            }
        }
    }
    
    private static func getUser(token: String, completion: @escaping (Result<User, AppError>) -> ()) {
        switch CoreDataHelper.fetchUser() {
        case .failure:
            DataService.instance.downloadUserDetails(token: token) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let user):
                    completion(Result.success(user))
                    DispatchQueue.main.async {
                        CoreDataHelper.saveUser(user: user)
                    }
                }
            }
        case .success(let user):
            completion(Result.success(user))
        }
    }
    
    
    static func login(initials: String, password: String, completion: @escaping (Result<Session, AppError>) -> ()) {
        DataService.instance.login(initials: initials, password: password) { (result) in
            switch result {
            case .success(let token):
                UserDefaultsHelper.token = token
                DispatchQueue.main.async {
                    Session.getUser(token: token, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            completion(Result.failure(error))
                        case .success(let user):
                            completion(Result.success(Session(token: token, user: user)))
                        }
                    })
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    
}

extension Session: SessionDelegate {
    func userUpdated(user: User) {
        self.user = user
    }
}

    fileprivate extension DataService {
        func login(initials: String, password: String, completion: @escaping (Result<String, AppError>) -> ()) {
            
            guard let data = try? JSONSerialization.data(withJSONObject: ["Initialer": initials, "password": password]) else {completion(Result.failure(DataServiceError.encodingError)); return}
            
            createDataTaskRequest(url: LOGIN_URL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: nil) { (result) in
                switch result {
                case .failure(let error):
                    switch error {
                    case .unAuthorized: completion(Result.failure(DataServiceError.loginError))
                    default: completion(Result.failure(error))
                    }
                    
                case .success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.failure(DataServiceError.extractionError)); return}
                    guard let dictionary = json as? [String: Any],  let token = dictionary["token"] as? String else {completion(Result.failure(DataServiceError.extractionError)); return}
                    completion(Result.success(token))
                }
            }
        }
        
        func getNotifications(userID: Int, token: String, limit: Int, offset: Int, completion: @escaping (Result<[UserNotification], AppError>) -> ()) {
            createDataTaskRequest(url: API.userNotificationsURL(userID:  userID, limit: limit, offset: offset), token: token) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    do {
                        let userNotificationJSON = try JSONDecoder().decode(UserNotificationJSON.self, from: data)
                        completion(Result.success(userNotificationJSON.results))
                    } catch {
                        completion(Result.failure(DataServiceError.decodingError(error)))
                    }
                }
            }
        }
    

        func getUserNotificationCount(token: String, completion: @escaping (Result<Int, AppError>) -> ()) {
            createDataTaskRequest(url: API.userNotificationsCountURL(), token: token) { (result) in
                switch result {
                case .success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.failure(DataServiceError.extractionError)); return}
                    guard let dictionary = json as? [String: Any], let count = dictionary["count"] as? Int else {completion(Result.failure(DataServiceError.extractionError)); return}
                    completion(Result.success(count))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
        }
        
        func downloadUserDetails(token: String, completion: @escaping (Result<User, AppError>) -> ()) {
            createDataTaskRequest(url: API.userURL(), token: token) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        completion(Result.success(user))
                    } catch {
                        completion(Result.failure(DataServiceError.decodingError(error)))
                    }
                }
            }
        }
        
        func getUserObservationsCount(userID: Int, completion: @escaping (Result<Int, AppError>) -> ()) {
            createDataTaskRequest(url: API.userObservationsCountURL(userID: userID)) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.failure(DataServiceError.extractionError)); return}
                    guard let array = json as? [[String: Any]], let dictionary = array.first, let count = dictionary["count"] as? Int else {completion(Result.failure(DataServiceError.extractionError)); return}
                    completion(Result.success(count))
                }
            }
        }
        
        func downloadUserObservations(limit: Int, offset: Int, userID: Int, completion: @escaping (Result<[Observation], AppError>) -> ()) {
            createDataTaskRequest(url: API.observationsURL(includeQueries: [.locality, .determinationView(taxonID: nil), .comments, .images, .geomNames, .user(responseFilteredByUserID: userID)], limit: limit, offset: offset)) { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let data):
                    do {
                        let observations = try JSONDecoder().decode([Observation].self, from: data)
                        completion(Result.success(observations))
                    } catch {
                        completion(Result.failure(DataService.DataServiceError.decodingError(error)))
                    }
                }
            }
        }
        
        func postComment(taxonID: Int, comment: String, token: String, completion: @escaping (Result<Comment, AppError>) -> ()) {
            
            let dictionary = ["content": comment]
            
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                createDataTaskRequest(url: API.Post.comment(taxonID: taxonID).encodedURL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: token) { (result) in
                    switch result {
                    case .failure(let error):
                        completion(Result.failure(error))
                    case .success(let data):
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                            
                            guard let id = json["_id"] as? Int, let date = json["createdAt"] as? String, let content = json["content"] as? String, let user = json["User"] as? Dictionary<String, Any>, let commentername = user["name"] as? String else {completion(Result.failure(DataServiceError.extractionError)); return}
                            let facebook = json["facebook"] as? String
                            let initials = user["Initialer"] as? String
                            
                            let comment = Comment(id: id, date: date, content: content, commenterName: commentername, initials: initials, commenterFacebookID: facebook)
                            completion(Result.success(comment))
                        } catch {
                            completion(Result.failure(DataServiceError.decodingError(error)))
                        }
                    }
                }
            } catch {
                completion(Result.failure(DataServiceError.encodingError))
            }
                    }
        
        
        func editObservation(withId id: Int, dict: [String: Any], newImageURLs: [URL], token: String, completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                createDataTaskRequest(url: API.Put.observation(id: id).encodedURL, method: "PUT", data: data, contentType: "application/json", token: token) { (result) in
                    
                    switch result {
                    case .failure(let error):
                        completion(Result.failure(error))
                    case .success(let data):
                        let json = try? JSONSerialization.jsonObject(with: data, options: [])
                        guard let dict = json as? Dictionary<String, Any> else {return}
                        
                        let observationID = (dict["_id"] as? Int)!
                        
                        self.uploadImages(observationID: observationID, imageURLs: newImageURLs, token: token, completion: { (result) in
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
        
        func postObservation(dict: [String: Any], imageURLs: [URL], token: String, completion: @escaping (Result<(observationID: Int, uploadedImagesCount: Int), AppError>) -> ()) {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                createDataTaskRequest(url: API.postObservationURL(), method: "POST", data: data, contentType: "application/json", token: token) { (result) in
                    
                    switch result {
                    case .failure(let error):
                        completion(Result.failure(error))
                    case .success(let data):
                        let json = try? JSONSerialization.jsonObject(with: data, options: [])
                        guard let dict = json as? Dictionary<String, Any> else {return}
                        
                        let observationID = (dict["_id"] as? Int)!
                        
                        self.uploadImages(observationID: observationID, imageURLs: imageURLs, token: token, completion: { (result) in
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
            createDataTaskRequest(url: API.Delete.observation(id: id).encodedURL, method: "DELETE", data: nil, contentType: nil, contentLenght: nil, token: token) { (result) in
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
            createDataTaskRequest(url: API.Delete.image(id: id).encodedURL, method: "DELETE", data: nil, contentType: nil, contentLenght: nil, token: token) { (result) in
                switch result {
                case .failure(let error): completion(.failure(error))
                case .success: completion(.success(()))
                }
            }
        }
        
        private func uploadImage(observationID: Int, imageURL: URL, token: String, completion: @escaping (Result<Void, AppError>) -> ()) {
           
            guard let media = ELMultipartFormData.Media(withImage: imageURL, forKey: "file") else {completion(Result.failure(DataServiceError.encodingError)); return}
            
            let boundary = "apiclient\(Date.timeIntervalSinceReferenceDate)"
            let data = ELMultipartFormData.createDataBody(withParameters: nil, media: media, boundary: boundary)
            
            createDataTaskRequest(url: API.postImageURL(observationID: observationID), method: "POST", data: data, contentType: "multipart/form-data; boundary=\(boundary)", contentLenght: nil, token: token) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                    completion(Result.failure(error))
                case .success(_):
                    completion(Result.success(()))
                }
            }
        }
        
        func postOffensiveContentComment(observationID: Int, comment: String?, token: String, completion: @escaping () -> ()) {
            
            do {
                let data = try JSONSerialization.data(withJSONObject: ["message": comment ?? ""], options: [])
                
                createDataTaskRequest(url: API.Post.offensiveContentComment(taxonID: observationID).encodedURL, method: "POST", data: data, contentType: "application/json", token: token) { (result) in
                    
                    switch result {
                    case .failure(_):
                        completion()
                    case .success(_):
                        completion()
                    }
                }
                
            } catch {
                debugPrint(error)
            }
        }
        
        func markNotificationAsRead(notificationID: Int, token: String) {
            createDataTaskRequest(url: API.Put.notificationLastRead(notificationID: notificationID).encodedURL, method: "PUT", token: token) { (result) in
                switch  result {
                case .failure(let error):
                    debugPrint(error)
                case .success(_):
                    return
                }
            }
        }
}


