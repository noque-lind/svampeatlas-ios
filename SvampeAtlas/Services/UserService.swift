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
        getUser(completion: nil)
    }
    
    public private(set) var isLoggedIn = true
    private var user: User?
    
    func getUser(completion: ((User?) -> ())? = nil) {
        if let user = user {
            completion?(user)
        } else {
            guard let token = UserDefaults.standard.string(forKey: "token") else {completion?(nil); return}
            getUserDetails(token: token) { (appError, user) in
                if let user = user {
                    self.user = user
                    completion?(user)
                }
            }
        }
    }
    
    func logOut() {
        user = nil
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    
    func login(initials: String, password: String, completion: @escaping (AppError?) -> ()) {
        var urlRequest = URLRequest(url: URL(string: LOGIN_URL)!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        let json = try? JSONSerialization.data(withJSONObject: ["Initialer": initials, "password": password])
        urlRequest.httpBody = json
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                self.handleLoginJSON(json: json)
                completion(nil)
            } catch let error as AppError {
                completion(error)
            } catch {
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"))
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    
    private func handleLoginJSON(json: Any) {
        guard let json = json as? [String: Any] else {return}
        guard let token = json["token"] as? String else {return}
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    
    private func getUserDetails(token: String, completion: @escaping (AppError?, User?) -> ()) {
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
    
    private func handleURLSession(data: Data?, response: URLResponse?, error: Error?) throws -> Data  {
        guard error == nil, let response = response as? HTTPURLResponse else {
            throw handleURLSessionError(error: error)
        }
        
        guard response.statusCode < 300 else {
            throw handleURLResponse(response: response)
        }
        
        guard let data = data else {throw AppError(title: "Ukendt fejl", message: "Prøv venligst igen")}
        return data
    }
    
    
    private func handleURLSessionError(error: Error?) -> AppError {
        let error = error! as NSError
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            return AppError(title: "Ingen internetforbindelse", message: "Forbind til internettet for at hente data")
        case NSURLErrorTimedOut:
            return AppError(title: "Time-out", message: "Andmodningen udløb, der kunne ikke fås noget svar fra databasen lige nu. Prøv igen senere")
        default:
            return AppError(title: "Test", message: "test")
        }
    }
    
    private func handleURLResponse(response: HTTPURLResponse) -> AppError {
        switch response.statusCode {
        case 401:
            return AppError(title: "Forkert kodeord", message: "Du har indtastet et forkert kodeord, prøv igen.")
        default:
            return AppError(title: "Uventet fejl", message: "Åh nej, det skete noget der ikke skulle ske. Prøv hvad du gjorde igen.")
        }
    }
}

