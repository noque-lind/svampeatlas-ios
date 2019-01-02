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
        
        let geometry = URLQueryItem(name: "geometry", value: geoJSON)
        let whereQuery = URLQueryItem(name: "where", value: whereQuery)
        components.queryItems = [geometry, whereQuery]
        
        if let percentEncodedQuery = components.percentEncodedQuery {
            components.percentEncodedQuery = percentEncodedQuery + API.includeQuery(includeQueries: [.images, .determinationView(taxonID: nil), .user(responseFilteredByUserID: nil), .locality])
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
        var request = URLRequest(url: URL.init(string: API.observationWithIDURL(observationID: id))!)
        request.timeoutInterval = 5
        print(request.url)
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
        var request = URLRequest(url: URL.init(string: API.observationsURL(includeQueries: [.determinationView(taxonID: id), .comments, .images, .locality, .user(responseFilteredByUserID: nil)]))!)
//        var request = URLRequest(url: URL.init(string: OBSERVATIONSFOR_URL(taxonID: id, limit: 24))!)
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
        var request = URLRequest(url: URL.init(string: API.observationsURL(includeQueries: [.determinationView(taxonID: nil), .comments, .images, .user(responseFilteredByUserID: id)]))!)
        request.timeoutInterval = 5
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
    
    func getNotificationsForUser(withID id: Int, limit: Int, offset: Int, completion: @escaping (AppError?, [UserNotification]?) -> ()) {
        var request = URLRequest(url: URL.init(string: API.userNotificationsURL(userID: id, limit: limit, offset: offset))!)
        request.timeoutInterval = 5
        guard let token = UserDefaults.standard.string(forKey: "token") else {completion(nil, nil); return}
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
    
    func getImage(forUrl url: String, size: imageSize = .full, completion: @escaping (UIImage, String) -> Void) {
        if let image = imagesCache.object(forKey: NSString.init(string: size.rawValue + url)) {
            completion(image, url)
        } else if let image = imagesCache.object(forKey: NSString.init(string: imageSize.mini.rawValue + url)) {
            completion(image, url)
            downloadImage(url: URL(string: size.rawValue + url)!, completion: completion)
        } else if FileManager.default.fileExists(atPath: (FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first!.appendingPathComponent(url).absoluteString)) {
            print("Image exists in document store")
        } else {
            let url = URL(string: size.rawValue + url)!
            downloadImage(url: url, completion: completion)
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping (UIImage, String) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = try? self.handleURLSession(data: data, response: response, error: error) else {return}
            guard let image = UIImage(data: data) else {return}
            self.imagesCache.setObject(image, forKey: NSString.init(string: url.absoluteString))
            DispatchQueue.main.async {
                completion(image, url.absoluteString)
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


extension DataService {
    func getVegetationTypes(completion: @escaping ([VegetationType]) -> ()) {
        var request = URLRequest(url: URL(string: API.vegetationTypeURL())!)
        
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let data = try self.handleURLSession(data: data, response: response, error: error)
                let vegetationTypes = try JSONDecoder().decode([VegetationType].self, from: data)
                completion(vegetationTypes)
            } catch let error as AppError {
//                completion(error, nil)
            } catch {
                debugPrint(error.localizedDescription)
//                completion(AppError(title: "Uventet fejl", message: "Prøv venligst igen"), nil)
                
            }
        }
        task.resume()
    }
    
    
    func getSubstrateGroups(completion: @escaping ([SubstrateGroup]) -> ()) {
        var request = URLRequest(url: URL(string: API.substrateURL())!)
        
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = try? self.handleURLSession(data: data, response: response, error: error) else {return}
            let JSON = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String: Any]]
            print(JSON)
            
            var substrateGroups = [SubstrateGroup]()
            
            for object in JSON {
                guard let hide = object["hide"] as? Bool, let id = object["_id"] as? Int, let name = object["name"] as? String, let name_uk = object["name_uk"] as? String, let group_dk = object["group_dk"] as? String, let group_uk = object["group_uk"] as? String, hide == false else {continue}
                
                if let substrateGroup = substrateGroups.first(where: {$0.dkName == group_dk}) {
                    substrateGroup.appendSubstrate(substrate: Substrate(id: id, dkName: name, enName: name_uk))
                } else {
                    substrateGroups.append(SubstrateGroup(dkName: group_dk, enName: group_uk, substrates: [Substrate(id: id, dkName: name, enName: name_uk)]))
                }
            }
        
                completion(substrateGroups)
        }
        task.resume()
    }
}
