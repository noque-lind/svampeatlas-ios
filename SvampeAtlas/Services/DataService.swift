//
//  DataService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


class DataService {
    private init() {}
    static let instance = DataService()
    
    private let imagesCache = NSCache<NSString, UIImage>()
    private let thumbImagesCache = NSCache<NSString, UIImage>()
    
    
    func getObservationsWithin(geoJSON: String, whereQuery: String?, completion: @escaping (AppError?, [Observation]?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = BASE_URL
        components.path = "/api/observations"
        
        let encodedQuery = "&include=%5B%22%7B%5C%22model%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22as%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22Taxon_id%5C%22%2C%5C%22Recorded_as_id%5C%22%2C%5C%22Taxon_FullName%5C%22%2C%5C%22Taxon_vernacularname_dk%5C%22%2C%5C%22Determination_validation%5C%22%2C%5C%22Determination_user_id%5C%22%2C%5C%22Determination_score%5C%22%2C%5C%22Determination_validator_id%5C%22%5D%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22User%5C%22%2C%5C%22as%5C%22%3A%5C%22PrimaryUser%5C%22%2C%5C%22required%5C%22%3Afalse%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22Locality%5C%22%2C%5C%22as%5C%22%3A%5C%22Locality%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22_id%5C%22%2C%5C%22name%5C%22%5D%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22ObservationUser%5C%22%2C%5C%22as%5C%22%3A%5C%22userIds%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22ObservationImage%5C%22%2C%5C%22as%5C%22%3A%5C%22Images%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22ObservationForum%5C%22%2C%5C%22as%5C%22%3A%5C%22Forum%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Afalse%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22Determination%5C%22%2C%5C%22as%5C%22%3A%5C%22Determinations%5C%22%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22attributes%5C%22%3A%5B%5C%22_id%5C%22%2C%5C%22score%5C%22%5D%2C%5C%22required%5C%22%3Afalse%7D%22%5D"
        
        
        
        let geometry = URLQueryItem(name: "geometry", value: geoJSON)
        let whereQuery = URLQueryItem(name: "where", value: whereQuery)
        components.queryItems = [geometry, whereQuery]
        
        if let percentEncodedQuery = components.percentEncodedQuery {
            components.percentEncodedQuery = percentEncodedQuery + encodedQuery
        }
        
        guard let url = components.url else {return}
        print(url)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let observations = try JSONDecoder().decode([Observation].self, from: data)
                completion(nil, observations)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
            }
        }
        task.resume()
    }
    
    func getMushrooms(offset: Int, completion: @escaping (AppError?, [Mushroom]?) -> Void) {
        var request = URLRequest(url: URL.init(string: ALLMUSHROOMS_URL(limit: 100, offset: offset))!)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let mushrooms = try JSONDecoder().decode([Mushroom].self, from: data)
                completion(nil, mushrooms)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
            }
        }
        task.resume()
    }
    
    func getMushroom(withID id: Int, completion: @escaping (AppError?, Mushroom?) -> Void) {
        var request = URLRequest(url: URL.init(string: MUSHROOM_URL(taxonID: id))!)
        request.timeoutInterval = 5
        print(request.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                guard let mushroom = (try JSONDecoder().decode([Mushroom].self, from: data)).first else {completion(nil, nil); return}
                completion(nil, mushroom)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
            }
        }
        task.resume()
    }
    
    func getObservation(withID id: Int, completion: @escaping (AppError?, Observation?) -> Void) {
        var request = URLRequest(url: URL.init(string: API.observationWithID(observationID: id))!)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let observation = try JSONDecoder().decode(Observation.self, from: data) 
                completion(nil, observation)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
            }
        }
        task.resume()
    }
    
    func getMushroomsThatFitSearch(searchString: String, completion: @escaping (AppError?, [Mushroom]?) -> Void) {
        var request = URLRequest(url: URL.init(string: SEARCHFORMUSHROOM_URL(searchTerm: searchString))!)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                do {
                    let data = try self.handleURLSession(data: data, response: response, error: error)
                    let mushrooms = try JSONDecoder().decode([Mushroom].self, from: data)
                    completion(nil, mushrooms)
                } catch let error as AppError {
                    completion(error, nil)
                } catch {
                    completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                }
            }
        }
        task.resume()
    }
    
    func getObservationsForMushroom(withID id: Int, completion: @escaping (AppError?, [Observation]?) -> Void) {
        var request = URLRequest(url: URL.init(string: OBSERVATIONSFOR_URL(taxonID: id, limit: 24))!)
        request.timeoutInterval = 5
        print(request.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let observations = try JSONDecoder().decode([Observation].self, from: data)
                completion(nil, observations)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                debugPrint(error.localizedDescription)
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                
            }
        }
        task.resume()
    }
    
    func getObservationsForUser(withID id: Int, completion: @escaping (AppError?, [Observation]?) -> ()) {
        var request = URLRequest(url: URL.init(string: OBSERVATIONSFOR_USER(withID: id))!)
        request.timeoutInterval = 5
        print(request.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let observations = try JSONDecoder().decode([Observation].self, from: data)
                completion(nil, observations)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                debugPrint(error.localizedDescription)
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                
            }
        }
        task.resume()
    }
    
    func getNotificationsForUser(withID id: Int, completion: @escaping (AppError?, [UserNotification]?) -> ()) {
        var request = URLRequest(url: URL.init(string: API.userNotificationsURL(userID: id))!)
        request.timeoutInterval = 5
        guard let token = UserDefaults.standard.string(forKey: "token") else {completion(nil, nil); return}
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request.url)
        print(token)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let userNotificationJSON = try JSONDecoder().decode(UserNotificationJSON.self, from: data)
                completion(nil, userNotificationJSON.results)
            } catch let error as AppError {
                completion(error, nil)
            } catch {
                debugPrint(error.localizedDescription)
                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
            }
        }
        task.resume()
    }
    
    enum imageSize: String {
        case full = ""
        case mini = "https://svampe.databasen.org/unsafe/175x175/"
    }
    
    func getImage(forUrl url: String, size: imageSize = .full, completion: @escaping (UIImage) -> Void) {
        if let image = imagesCache.object(forKey: NSString.init(string: size.rawValue + url)) {
            completion(image)
        } else if let image = imagesCache.object(forKey: NSString.init(string: imageSize.mini.rawValue + url)) {
            completion(image)
            downloadImage(url: URL(string: size.rawValue + url)!, completion: completion)
        } else if FileManager.default.fileExists(atPath: (FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url).absoluteString)) {
            print("Image exists in document store")
        } else {
            let url = URL(string: size.rawValue + url)!
            downloadImage(url: url, completion: completion)
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping (UIImage) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = try? self.handleURLSession(data: data, response: response, error: error) else {return}
            guard let image = UIImage(data: data) else {return}
            self.imagesCache.setObject(image, forKey: NSString.init(string: url.absoluteString))
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
    
    internal func handleURLSession(data: Data?, response: URLResponse?, error: Error?) throws -> Data  {
        guard error == nil, let response = response as? HTTPURLResponse else {
            throw handleURLSessionError(error: error)
        }
        
        guard response.statusCode < 300 else {
            throw handleURLResponse(response: response)
        }
        
        guard let data = data else {throw AppError(title: "Ukendt fejl", message: "Prøv venligst igen")}
        return data
    }
    
    
    internal func handleURLSessionError(error: Error?) -> AppError {
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
    
    internal func handleURLResponse(response: HTTPURLResponse) -> AppError {
        switch response.statusCode {
        case 401:
            return AppError(title: "Forkert kodeord", message: "Forkert kodeord")
        default:
        return AppError(title: "Uventet Fejl", message: "Uventet Fejl, Prøv igen")
    }
}
}
