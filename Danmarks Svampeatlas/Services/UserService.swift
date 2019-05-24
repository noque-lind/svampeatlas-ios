//
//  UserService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation



protocol SessionDelegate: class {
    func userUpdated(user: User)
}

class Session {
    
    enum SessionError: AppError {
        var errorDescription: String {
            switch self {
            case .notLoggedIn:
                return "Du er ikke logget ind"
            case .tokenInvalid:
                return  "Dit login er ikke længere gyldig, login igen."
            case .noNotifications:
                return "Mere tid til at finde svampe, wuhu!"
            case .noObservations:
                return "Kan du så komme igang med at finde nogle svampe"
            }
        }
        
        var errorTitle: String {
            switch self {
            case .notLoggedIn:
                return "Login fejl"
            case .tokenInvalid:
                return "Ugyldigt login"
            case .noNotifications:
                return "Du har ingen notifikationer"
            case .noObservations:
                return "Du har ingen observationer"
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
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let count):
                completion(Result.Success(count))
            }
        }
    }
    
    func getObservationsCount(completion: @escaping (Result<Int, AppError>) -> ()) {
        DataService.instance.getUserObservationsCount(userID: user.id) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let count):
                completion(Result.Success(count))
            }
        }
    }
    
    func getUserNotifications(limit: Int, offset: Int, completion: @escaping (Result<[UserNotification], AppError>) -> ()) {
        DataService.instance.getNotifications(userID: user.id, token: token, limit: limit, offset: offset) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let userNotifications):
                guard userNotifications.count != 0 else {completion(Result.Error(SessionError.noNotifications)); return}
                completion(Result.Success(userNotifications))
            }
        }
    }
    
    func getObservations(limit: Int, offset: Int, completion: @escaping (Result<[Observation], AppError>) -> ()) {
        DataService.instance.downloadUserObservations(limit: limit, offset: offset, userID: user.id) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let observations):
                guard observations.count != 0 else {completion(Result.Error(SessionError.noObservations)); return}
                completion(Result.Success(observations))
            }
        }
    }
    
    func uploadComment(observationID: Int, comment: String, completion: @escaping (Result<Comment, AppError>) -> ()) {
        DataService.instance.postComment(taxonID: observationID, comment: comment, token: token, completion: completion)
    }
}

//MARK: Static functions
extension Session {
    static func resumeSession(completion: @escaping (Result<Session, AppError>) -> ()) {
        guard let token = UserDefaultsHelper.token else {completion(Result.Error(SessionError.notLoggedIn)); return}
        getUser(token: token) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let user):
                completion(Result.Success(Session(token: token, user: user)))
            }
        }
    }
    
    private static func getUser(token: String, completion: @escaping (Result<User, AppError>) -> ()) {
        switch CoreDataHelper.fetchUser() {
        case .Error:
            DataService.instance.downloadUserDetails(token: token) { (result) in
                switch result {
                case .Error(let error):
                    completion(Result.Error(error))
                case .Success(let user):
                    completion(Result.Success(user))
                    DispatchQueue.main.async {
                        CoreDataHelper.saveUser(user: user)
                    }
                }
            }
        case .Success(let user):
            completion(Result.Success(user))
        }
    }
    
    
    static func login(initials: String, password: String, completion: @escaping (Result<Session, AppError>) -> ()) {
        DataService.instance.login(initials: initials, password: password) { (result) in
            switch result {
            case .Success(let token):
                UserDefaultsHelper.token = token
                DispatchQueue.main.async {
                    Session.getUser(token: token, completion: { (result) in
                        switch result {
                        case .Error(let error):
                            completion(Result.Error(error))
                        case .Success(let user):
                            completion(Result.Success(Session(token: token, user: user)))
                        }
                    })
                }
            case .Error(let error):
                completion(Result.Error(error))
            }
        }
    }
    
    
}

extension Session: SessionDelegate {
    func userUpdated(user: User) {
        self.user = user
    }
}

    extension DataService {
        fileprivate func login(initials: String, password: String, completion: @escaping (Result<String, AppError>) -> ()) {
            
            guard let data = try? JSONSerialization.data(withJSONObject: ["Initialer": initials, "password": password]) else {completion(Result.Error(DataServiceError.encodingError)); return}
            
            createDataTaskRequest(url: LOGIN_URL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: nil) { (result) in
                switch result {
                case .Error(let error):
                    switch error {
                    case .unAuthorized: completion(Result.Error(DataServiceError.loginError))
                    default: completion(Result.Error(error))
                    }
                    
                case .Success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.Error(DataServiceError.extractionError)); return}
                    guard let dictionary = json as? [String: Any],  let token = dictionary["token"] as? String else {completion(Result.Error(DataServiceError.extractionError)); return}
                    completion(Result.Success(token))
                }
            }
        }
        
        fileprivate func getNotifications(userID: Int, token: String, limit: Int, offset: Int, completion: @escaping (Result<[UserNotification], AppError>) -> ()) {
            createDataTaskRequest(url: API.userNotificationsURL(userID:  userID, limit: limit, offset: offset), token: token) { (result) in
                switch result {
                case .Error(let error):
                    completion(Result.Error(error))
                case .Success(let data):
                    do {
                        let userNotificationJSON = try JSONDecoder().decode(UserNotificationJSON.self, from: data)
                        completion(Result.Success(userNotificationJSON.results))
                    } catch {
                        completion(Result.Error(DataServiceError.decodingError(error)))
                    }
                }
            }
        }
    

        fileprivate func getUserNotificationCount(token: String, completion: @escaping (Result<Int, AppError>) -> ()) {
            createDataTaskRequest(url: API.userNotificationsCountURL(), token: token) { (result) in
                switch result {
                case .Success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.Error(DataServiceError.extractionError)); return}
                    guard let dictionary = json as? [String: Any], let count = dictionary["count"] as? Int else {completion(Result.Error(DataServiceError.extractionError)); return}
                    completion(Result.Success(count))
                case .Error(let error):
                    completion(Result.Error(error))
                }
            }
        }
        
        fileprivate func downloadUserDetails(token: String, completion: @escaping (Result<User, AppError>) -> ()) {
            createDataTaskRequest(url: API.userURL(), token: token) { (result) in
                switch result {
                case .Error(let error):
                    completion(Result.Error(error))
                case .Success(let data):
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        completion(Result.Success(user))
                    } catch {
                        completion(Result.Error(DataServiceError.decodingError(error)))
                    }
                }
            }
        }
        
        fileprivate func getUserObservationsCount(userID: Int, completion: @escaping (Result<Int, AppError>) -> ()) {
            createDataTaskRequest(url: API.userObservationsCountURL(userID: userID)) { (result) in
                switch result {
                case .Error(let error):
                    completion(Result.Error(error))
                case .Success(let data):
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {completion(Result.Error(DataServiceError.extractionError)); return}
                    guard let array = json as? [[String: Any]], let dictionary = array.first, let count = dictionary["count"] as? Int else {completion(Result.Error(DataServiceError.extractionError)); return}
                    completion(Result.Success(count))
                }
            }
        }
        
        fileprivate func downloadUserObservations(limit: Int, offset: Int, userID: Int, completion: @escaping (Result<[Observation], AppError>) -> ()) {
            createDataTaskRequest(url: API.observationsURL(includeQueries: [.locality, .determinationView(taxonID: nil), .comments, .images, .user(responseFilteredByUserID: userID)], limit: limit, offset: offset)) { (result) in
                switch result {
                case .Error(let error):
                    completion(Result.Error(error))
                case .Success(let data):
                    do {
                        let observations = try JSONDecoder().decode([Observation].self, from: data)
                        completion(Result.Success(observations))
                    } catch {
                        completion(Result.Error(DataService.DataServiceError.decodingError(error)))
                    }
                }
            }
        }
        
        fileprivate func postComment(taxonID: Int, comment: String, token: String, completion: @escaping (Result<Comment, AppError>) -> ()) {
            
            let dictionary = ["content": comment]
            
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                createDataTaskRequest(url: API.Post.comment(taxonID: taxonID).encodedURL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: token) { (result) in
                    switch result {
                    case .Error(let error):
                        completion(Result.Error(error))
                    case .Success(let data):
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
                            
                            guard let id = json["_id"] as? Int, let date = json["createdAt"] as? String, let content = json["content"] as? String, let user = json["User"] as? Dictionary<String, Any>, let commentername = user["name"] as? String else {completion(Result.Error(DataServiceError.extractionError)); return}
                            let facebook = json["facebook"] as? String
                            let initials = user["Initialer"] as? String
                            
                            let comment = Comment(id: id, date: date, content: content, commenterName: commentername, initials: initials, commenterFacebookID: facebook)
                            completion(Result.Success(comment))
                        } catch {
                            completion(Result.Error(DataServiceError.decodingError(error)))
                        }
                    }
                }
            } catch {
                completion(Result.Error(DataServiceError.encodingError))
            }
            
            
            
                    }
     
}


