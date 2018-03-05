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
    
    func getMushrooms(completion: @escaping ([Mushroom]) -> Void) {
        let request = URLRequest(url: URL.init(string: BASE_URL)!)
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
        print(url)
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let response = response as? HTTPURLResponse else {return}
//            print(response)
            guard let data = data else {return}
            guard let image = UIImage(data: data) else {return}
            completion(image)
        }
        task.resume()
    }
    
    
}
