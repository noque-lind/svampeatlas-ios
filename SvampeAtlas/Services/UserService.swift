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
    
    private init() {}
    
    public private(set) var isLoggedIn = true
    private var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOjI3MDYsImlhdCI6MTUzOTc3Nzg1Mn0.J0FKieI-ABCv8q5k05eAyKwuH_CX7pI9a_RsEYU-FxU"
    
    
    
    
    func getUserDetails(completion: @escaping (AppError?, User?) -> ()) {
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
        return AppError(title: "test", message: "test")
    }
}

