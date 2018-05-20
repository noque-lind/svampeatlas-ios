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
    
    
    func getObservationsWithin(geoJSON: String, completion: @escaping ([Observation]) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = BASE_URL
        components.path = "/api/observations"
        
        let encodedQuery = "&include=%5B%22%7B%5C%22model%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22as%5C%22%3A%5C%22DeterminationView%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22Taxon_id%5C%22%2C%5C%22Recorded_as_id%5C%22%2C%5C%22Taxon_FullName%5C%22%2C%5C%22Taxon_vernacularname_dk%5C%22%2C%5C%22Taxon_RankID%5C%22%2C%5C%22Determination_validation%5C%22%2C%5C%22Taxon_redlist_status%5C%22%2C%5C%22Taxon_path%5C%22%2C%5C%22Recorded_as_FullName%5C%22%2C%5C%22Determination_user_id%5C%22%2C%5C%22Determination_score%5C%22%2C%5C%22Determination_validator_id%5C%22%5D%2C%5C%22where%5C%22%3A%7B%5C%22%24and%5C%22%3A%7B%5C%22%24or%5C%22%3A%7B%7D%7D%7D%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22User%5C%22%2C%5C%22as%5C%22%3A%5C%22PrimaryUser%5C%22%2C%5C%22required%5C%22%3Afalse%2C%5C%22where%5C%22%3A%7B%7D%7D%22%2C%22%7B%5C%22model%5C%22%3A%5C%22Locality%5C%22%2C%5C%22as%5C%22%3A%5C%22Locality%5C%22%2C%5C%22attributes%5C%22%3A%5B%5C%22_id%5C%22%2C%5C%22name%5C%22%5D%2C%5C%22where%5C%22%3A%7B%7D%2C%5C%22required%5C%22%3Atrue%7D%22%5D%0A"
        
    
    
        let geometry = URLQueryItem(name: "geometry", value: geoJSON)
        components.queryItems = [geometry]
        if let percentEncodedQuery = components.percentEncodedQuery {
            components.percentEncodedQuery = percentEncodedQuery + encodedQuery
        }
        
        guard let url = components.url else {return}
//            print(url)
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
            print(response.statusCode)
            
            guard let data = data else {print("wth"); return}
            
            do {
                let observations = try JSONDecoder().decode([Observation].self, from: data)
                completion(observations)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getMushrooms(completion: @escaping ([Mushroom]) -> Void) {
        let request = URLRequest(url: URL.init(string: BASE_URL_OLD)!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
            print(response.statusCode)
            
            guard let data = data else {print("wth"); return}
            
            do {
                let mushrooms = try JSONDecoder().decode([Mushroom].self, from: data)
                completion(mushrooms)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getThumbImageForMushroom(url: String, completion: @escaping (UIImage) -> Void) {
        if let image = imagesCache.object(forKey: NSString.init(string: url)) {
            completion(image)
        } else {
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            guard let image = UIImage(data: data) else {return}
            self.imagesCache.setObject(image, forKey: NSString.init(string: url))
            completion(image)
        }
        task.resume()
    }
    }
    
    func getImage(forUrl url: String, completion: @escaping (UIImage) -> Void) {
        if let image = imagesCache.object(forKey: NSString.init(string: url)) {
            completion(image)
        } else {
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
            //            print(response)
            guard let data = data else {return}
            guard let image = UIImage(data: data) else {return}
            self.imagesCache.setObject(image, forKey: NSString.init(string: url))
            completion(image)
        }
        task.resume()
    }
    }
}
