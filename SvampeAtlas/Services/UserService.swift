//
//  UserService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

class UserService {
    static let instance = UserService()
    
    private init() {
        if let token = UserDefaults.standard.string(forKey: "token") {
            self.token = token
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
        }
    }
    
    public private(set) var isLoggedIn: Bool
    private var token: String?
    private var user: User?
    private var userNotificationCount: Int?
    
    func getUserDetails(completion: @escaping (User?) -> ()) {
        if let user = user {
            completion(user)
        } else {
            CoreDataHelper.fetchUser { (user) in
            guard let user = user else {return}
            self.user = user
            completion(user)
            }
        }
        
        guard let token = token else {completion(nil); return}
        DataService.instance.getUserDetails(token: token) { (appError, user) in
            guard let user = user, self.user != user else {return}
            self.user = user
            CoreDataHelper.saveUser(user: user, completion: {
                print("User succesfully saved")
            })
            completion(user)
        }
    }
    
    func getUserNotificationCount(completion: @escaping (Int?) -> ()) {
        guard let token = token else {completion(nil); return}
        if let count = userNotificationCount {
            completion(count)
        }
        
        DataService.instance.getUserNotificationCount(token: token) { (count) in
            self.userNotificationCount = count
            completion(count)
        }
    }
    
    func logOut() {
        isLoggedIn = false
        user = nil
        token = nil
        UserDefaults.standard.removeObject(forKey: "token")
        CoreDataHelper.deleteUser {
            
        }
    }
    
    func login(initials: String, password: String, completion: @escaping (AppError?) -> ()) {
        DataService.instance.login(initials: initials, password: password) { (appError, token) in
            guard let token = token else {completion(appError); return}
            UserDefaults.standard.set(token, forKey: "token")
            self.token = token
            self.isLoggedIn = true
            completion(nil)
        }
    }
}


    extension DataService {
        fileprivate func login(initials: String, password: String, completion: @escaping (AppError?, String?) -> ()) {
            var urlRequest = URLRequest(url: URL(string: LOGIN_URL)!)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            
            let json = try? JSONSerialization.data(withJSONObject: ["Initialer": initials, "password": password])
            urlRequest.httpBody = json
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                do {
                    let data = try self.handleURLSession(data: data, response: response, error: error)
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    let token = try self.extractTokenFromJSON(json: json)
                    completion(nil, token)
                } catch let error as AppError {
                    completion(error, nil)
                } catch {
                    completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                }
            }
            task.resume()
        }

        fileprivate func getUserNotificationCount(token: String, completion: @escaping (Int?) -> ()) {
            var urlRequest = URLRequest(url: URL(string: API.userNotificationsCountURL())!)
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                do {
                    let data = try self.handleURLSession(data: data, response: response, error: error)
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    let count = try self.extractCountFromJSON(json: json)
                    completion(count)
                } catch let error as AppError {
                    completion(nil)
                } catch {
                    completion(nil)
                }
            }
            task.resume()
        }
        
        fileprivate func getUserDetails(token: String, completion: @escaping (AppError?, User?) -> ()) {
            var urlRequest = URLRequest(url: URL(string: ME_URL)!)
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                do {
                    let data = try self.handleURLSession(data: data, response: response, error: error)
                    let user = try JSONDecoder().decode(User.self, from: data)
                    completion(nil, user)
                } catch let error as AppError {
                    completion(error, nil)
                } catch {
                    completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                }
            }
            task.resume()
        }
        
        private func extractTokenFromJSON(json: Any) throws -> String?  {
        guard let json = json as? [String: Any] else {throw AppError.init(title: "Fejl", message: "Ikke et validt svar fra serveren")}
        guard let token = json["token"] as? String else {throw AppError.init(title: "Fejl", message: "Kunne ikke hente sikkerhedstoken")}
        return token
    }
        
        private func extractCountFromJSON(json: Any) throws -> Int? {
            guard let json = json as? [String: Any] else {throw AppError.init(title: "Fejl", message: "Ikke et validt svar fra serveren")}
            guard let count = json["count"] as? Int else {throw AppError.init(title: "Fejl", message: "Kunne ikke extracte count")}
            return count
        }
}


