//
//  DataService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

enum Result<ReturnValue, ErrorType> {
    case Error(ErrorType)
    case Success(ReturnValue)
}

class DataService{
    
    enum DataServiceError: AppError {
        
        case decodingError(Error)
        case encodingError
        case searchReponseEmpty
        case extractionError
        case loginError
        case unhandled
        case empty
        
        var recoveryAction: RecoveryAction? {
            return nil
        }
        
        var errorDescription: String {
            switch self {
            case .decodingError(let error):
                debugPrint(error)
                return ""
            case .searchReponseEmpty:
                return "Det du søgte efter kunne ikke findes, prøv at søg efter noget andet"
            case .loginError:
                return "Prøv nogle andre initialer eller et andet kodeord"
            case .empty:
                return "Tom"
            default:
                return "Unhandled DataServiceError"
            }
        }
        
        var errorTitle: String {
            switch self {
            case .searchReponseEmpty:
                return "Fandt intet"
            case .decodingError:
                return "Fejl"
            case .encodingError:
                return "Der skete en fejl med at "
            case .loginError:
                return "Kunne ikke logge ind"
            case .empty:
                return "Tom"
            default:
                return "Unhandled DataServiceError"
            }
        }
    }
    
    enum URLSessionError: AppError {
        
        
        case noInternet
        case timeout
        case invalidResponse
        case serverError
        case unAuthorized
        case unknown
        case payloadTooLarge
        
        
        var errorDescription: String {
            switch self {
            case .noInternet:
                return "Du er ikke på internettet. Hvis du spørger din nabo sødt, må du måske bruge hans WiFi."
            case .invalidResponse:
                return "Svaret jeg fik tilbage fra serveren, giver desværre ingen mening. Prøv igen"
            case .serverError:
                return "Det lader til at der er et problem med serveren lige nu. Måske trænger den til et kram?"
            case .timeout:
                return "Det tog for lang tid før svaret nåede frem. Prøv igen, det kan være jeg var for utålmodig"
            case .unknown:
                return "Der skete en fejl, som jeg ikke ved hvorfor skete. Øv bøv."
            case .unAuthorized:
                return "Du er ikke logget på"
            case .payloadTooLarge:
                return "Serveren kan ikke håndterere for stor data, prøv at send mindre."
            }
        }
        
        var errorTitle: String {
            switch self {
            case .noInternet:
                return "Ingen internet"
            case .invalidResponse:
                return "Ugyldigt svar"
            case .serverError:
                return "Server fejl"
            case .timeout:
                return "Time-out"
            case .unknown:
                return "Ukendt fejl"
            case .unAuthorized:
                return "Uautoriseret"
            case .payloadTooLarge:
                return "Anmodningen var for stor"
            }
        }
        
        var recoveryAction: RecoveryAction? {
            switch self {
            case .unAuthorized: return .login
            default: return .tryAgain
            }
        }
    }
    
    
    private init() {}
    static let instance = DataService()
    weak var sessionDelegate: SessionDelegate?
    private let imagesCache = NSCache<NSString, UIImage>()
    private let mushroomCache = NSCache<NSString, NSData>()
    private var currentlyDownloading = Dictionary<String, URLSessionTask>()
    
    //CLASS FUNCTIONS
    
    internal func createDataTaskRequest(url: String, method: String = "GET", data: Data? = nil, contentType: String? = nil, contentLenght: Int? = nil, token: String? = nil, completion: @escaping (Result<Data, URLSessionError>) -> ()) {
        var request = URLRequest(url: URL.init(string: url)!)
        request.timeoutInterval = 20
        request.httpMethod = method
        request.httpBody = data
        
        if let contentType = contentType {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        if let contentLenght = contentLenght {
            request.addValue(String(contentLenght), forHTTPHeaderField: "Content-Lenght")
        }
        
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
    
                let data = try self.handleURLSession(data: data, response: response, error: error)
                completion(Result.Success(data))
            } catch let error as URLSessionError {
                completion(Result.Error(error))
            } catch {
                completion(Result.Error(URLSessionError.unknown))
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
        
        guard let data = data else {throw URLSessionError.invalidResponse}
        return data
    }
    
    
    internal func handleURLSessionError(error: Error?) -> URLSessionError {
        let error = error! as NSError
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            return URLSessionError.noInternet
        case NSURLErrorTimedOut:
            return URLSessionError.timeout
        default:
            return URLSessionError.unknown
        }
    }
    
    internal func handleURLResponse(response: HTTPURLResponse) -> URLSessionError {
        switch response.statusCode {
        case 401:
            return URLSessionError.unAuthorized
        case 500:
            return URLSessionError.serverError
        case 413:
            return URLSessionError.payloadTooLarge
        default:
            return URLSessionError.unknown
        }
    }
}

extension DataService {
    
    //FUNCTIONS THAT RETURN MUSHROOM/S
    
    func getMushrooms(searchString: String?, speciesQueries: [API.SpeciesQueries] = [API.SpeciesQueries.danishNames, API.SpeciesQueries.attributes(presentInDenmark: nil), API.SpeciesQueries.images(required: false), API.SpeciesQueries.statistics, API.SpeciesQueries.redlistData], limit: Int = 100, offset: Int = 0, completion: @escaping (Result<[Mushroom], AppError>) -> ()) {
        
        let api = API.Request.Mushrooms(searchString: searchString, speciesQueries: speciesQueries, limit: limit, offset: offset).encodedURL
        
        func handleData(data: Data) {
            do {
                                       self.mushroomCache.setObject(NSData(data: data), forKey: NSString(string: api))
                                          
                                          let mushrooms = try JSONDecoder().decode([Mushroom].self, from: data)
                                          
                                          if searchString != nil && mushrooms.count == 0 {
                                              completion(Result.Error(DataServiceError.searchReponseEmpty))
                                          } else {
                                              completion(Result.Success(mushrooms))
                                          }
                                      } catch {
                                          completion(Result.Error(DataServiceError.decodingError(error)))
                                      }
        }
        
        
        
        
        if let data = mushroomCache.object(forKey: NSString(string: api)) {
            handleData(data: Data(data))
        } else {
            createDataTaskRequest(url: api) { (result) in
                       switch result {
                       case .Error(let error):
                           completion(Result.Error(error))
                       case .Success(let data):
                        handleData(data: data)
                       }
                   }
        }
    }
    
    func getMushroom(withID id: Int, completion: @escaping (Result<Mushroom, AppError>) -> ()) {
        createDataTaskRequest(url: API.Request.Mushroom(id: id).encodedURL) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let data):
                do {
                    guard let mushroom = try JSONDecoder().decode([Mushroom].self, from: data).first else {completion(Result.Error(DataServiceError.extractionError)); return}
                    completion(Result.Success(mushroom))
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
            }
        }
    }
}

extension DataService {
    
    // FUNCTIONS THAT RETURN OBSERVATION/S
    
    func getObservation(withID id: Int, completion: @escaping (Result<Observation, AppError>) -> ()) {
        createDataTaskRequest(url: API.observationWithIDURL(observationID: id)) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let data):
                do {
                    let observation = try JSONDecoder().decode(Observation.self, from: data)
                    completion(Result.Success(observation))
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
            }
        }
    }
    
    func getObservationsForMushroom(withID id: Int, limit: Int, offset: Int, completion: @escaping (Result<[Observation], AppError>) -> ()) {
        createDataTaskRequest(url: API.observationsURL(includeQueries: [.comments, .determinationView(taxonID: id), .geomNames, .images, .locality, .user(responseFilteredByUserID: nil)], limit: limit, offset: offset)) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let data):
                do {
                    let observations = try JSONDecoder().decode([Observation].self, from: data)
                    completion(Result.Success(observations))
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
            }
        }
    }
    
    
    func getObservationsWithin(geometry: API.Geometry, taxonID: Int? = nil, ageInYear: Int? = nil, completion: @escaping (Result<[Observation], AppError>) -> ()) {
        createDataTaskRequest(url: API.Request.Observation(geometry: geometry, ageInYear: ageInYear, include: [.comments, .determinationView(taxonID: taxonID), .geomNames, .images, .locality, .user(responseFilteredByUserID: nil)], limit: nil, offset: nil).encodedURL) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let data):
                do {
                    let observations = try JSONDecoder().decode([Observation].self, from: data)
                    completion(Result.Success(observations))
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
            }
        }
    }
}

extension DataService {
    
    // POST and UPLOAD FUNCTIONS
}

extension DataService {
    
    // UTILITY DOWNLOADS
    
    func getLocalitiesNearby(coordinates: CLLocationCoordinate2D, radius: API.Radius = API.Radius.smallest, completion: @escaping (Result<[Locality], AppError>) -> ()) {
        
        createDataTaskRequest(url: API.localitiesURL(coordinates: coordinates, radius: radius)) { (result) in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Success(let data):
                do {
                    if radius != API.Radius.country {
                        let localities = try JSONDecoder().decode([Locality].self, from: data)
                        if localities.count <= 3 {
                            var newRadius: API.Radius
                            
                            switch radius {
                            case .smallest: newRadius = .smaller
                            case .smaller: newRadius = .small
                            case .small: newRadius = .medium
                            case .medium: newRadius = .large
                            case .large: newRadius = .larger
                            case .larger: newRadius = .largest
                            case .largest: newRadius = .huge
                            case .huge: newRadius = .huger
                            case .huger: newRadius = .hugest
                            case .hugest: if localities.count != 0 {completion(Result.Success(localities)); return} else { newRadius = .country}
                            case .country: return
                            }
                            
                            self.getLocalitiesNearby(coordinates: coordinates, radius: newRadius, completion: completion)
                        } else {
                            completion(Result.Success(localities))
                        }
                    } else {
                        guard let geoName = (try JSONDecoder().decode(GeoNames.self, from: data)).geonames.first else {completion(Result.Error(DataServiceError.extractionError)); return}
                        
                        
                        completion(Result.Success([Locality(id: geoName.geonameId, name: "\(geoName.name), \(geoName.countryCode)", latitude: Double(geoName.lat)!, longitude: Double(geoName.lng)!, geoName: geoName)]))
                    }
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
            }
        }
    }
    
  func getSubstrateGroups(overrideOutdateError: Bool? = false, completion: @escaping (Result<[SubstrateGroup], AppError>) -> ()) {
    
    func sortAndComplete(substrateGroups: [SubstrateGroup]) {
        let sortedSubstrateGroups = substrateGroups.sorted(by: {$0.id < $1.id})
        completion(Result.Success(sortedSubstrateGroups))
    }
    
        CoreDataHelper.fetchSubstrateGroups(overrideOutdateWarning: overrideOutdateError, completion: { [weak self] (result) in
            switch result {
            case .Success(let substrateGroups):
                sortAndComplete(substrateGroups: substrateGroups)
            case .Error(let coreDataError):
                switch coreDataError {
                case .noEntries, .readError:
                    self?.downloadSubstrateGroups(completion: { (result) in
                        switch result {
                        case .Error(let error):
                            completion(Result.Error(error))
                        case .Success(let substrateGroups):
                            sortAndComplete(substrateGroups: substrateGroups)
                        }
                    })
                case .contentOutdated:
                    self?.downloadSubstrateGroups(completion: { (result) in
                        switch result {
                        case .Success(let substrateGroups):
                            sortAndComplete(substrateGroups: substrateGroups)
                        case .Error(_):
                            self?.getSubstrateGroups(overrideOutdateError: true, completion: completion)
                            }
                    })
                case .saveError: return
                }
            }
        })
    }
    
    private func downloadSubstrateGroups(completion: @escaping (Result<[SubstrateGroup], AppError>) -> ()) {
        createDataTaskRequest(url: API.substrateURL()) { (result) in
            switch result {
            case .Success(let data):
                
                guard let JSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String: Any]] else {completion(Result.Error(DataServiceError.extractionError)); return}
                
                var substrateGroups = [SubstrateGroup]()
                
                for object in JSON {
                    guard let hide = object["hide"] as? Bool, let id = object["_id"] as? Int, let name = object["name"] as? String, let name_uk = object["name_uk"] as? String, let group_dk = object["group_dk"] as? String, let group_uk = object["group_uk"] as? String, hide == false else {continue}
                    
                    if let index = substrateGroups.firstIndex(where: {$0.dkName == group_dk}) {
                        substrateGroups[index].appendSubstrate(substrate: Substrate(id: id, dkName: name, enName: name_uk))
                    } else {
                        substrateGroups.append(SubstrateGroup(dkName: group_dk, enName: group_uk, substrates: [Substrate(id: id, dkName: name, enName: name_uk)]))
                    }
                }
                
        
                CoreDataHelper.saveSubstrateGroups(substrateGroups: substrateGroups)
                completion(Result.Success(substrateGroups))
                
            case .Error(let error):
                completion(Result.Error(error))
            }
        }
    }
    
    func getVegetationTypes(overrideOutdateWarning: Bool? = false, completion: @escaping (Result<[VegetationType], AppError>) -> ()) {
        CoreDataHelper.fetchVegetationTypes(overrideOutdateWarning: overrideOutdateWarning, completion: { (result) in
            switch result {
            case .Success(let vegetationTypes):
                let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                completion(Result.Success(sortedVegetationTypes))
            case .Error(let coreDataError):
                switch coreDataError {
                case .noEntries, .readError:
                    downloadVegetationTypes(completion: { (result) in
                        switch result {
                        case .Error(let error):
                            completion(Result.Error(error))
                        case .Success(let vegetationTypes):
                            let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                            completion(Result.Success(sortedVegetationTypes))
                        }
                    })
                case .contentOutdated:
                    downloadVegetationTypes(completion: { (result) in
                        switch result {
                        case .Success(let vegetationTypes):
                            let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                            completion(Result.Success(sortedVegetationTypes))
                        case .Error(_):
                            self.getVegetationTypes(overrideOutdateWarning: true, completion: completion)
                        }
                    })
                case .saveError:
                    return
                }
            }
        })
    }
    
   
    private func downloadVegetationTypes(completion: @escaping (Result<[VegetationType], AppError>) -> ()) {
        createDataTaskRequest(url: API.vegetationTypeURL(), completion: { (result) in
            switch result {
            case .Success(let data):
                guard let JSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String: Any]] else {completion(Result.Error(DataServiceError.extractionError)); return}
                
                var vegetationTypes = [VegetationType]()
                
                for object in JSON {
                    guard let id = object["_id"] as? Int, let name_uk = object["name_uk"] as? String, let name = object["name"] as? String else {continue}
                    vegetationTypes.append(VegetationType(id: id, dkName: name, enName: name_uk))
                }
                completion(Result.Success(vegetationTypes))
                CoreDataHelper.saveVegetationTypes(vegetationTypes: vegetationTypes)
            case .Error(let error):
                completion(Result.Error(error))
            }
        })
    }
    
    
    func getPopularHosts(overrideOutdateWarning: Bool? = false, completion: @escaping (Result<[Host], AppError>) -> ()) {
        CoreDataHelper.fetchHosts(overrideOutdateWarning: overrideOutdateWarning) { (result) in
            switch result {
            case .Success(let hosts):
                let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                completion(Result.Success(sortedHosts))
            case .Error(let coreDataError):
                switch coreDataError {
                case .noEntries, .readError:
                    downloadHosts(shouldSave: true, completion: { (result) in
                        switch result {
                        case .Error(let error):
                            completion(Result.Error(error))
                        case .Success(let hosts):
                            let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                            completion(Result.Success(sortedHosts))
                        }
                    })
                case .contentOutdated:
                    downloadHosts(shouldSave: true, completion: { (result) in
                        switch result {
                        case .Error(_):
                            self.getPopularHosts(overrideOutdateWarning: true, completion: completion)
                        case .Success(let hosts):
                            let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                            completion(Result.Success(sortedHosts))
                        }
                    })
                case .saveError: return
                }
            }
        }
    }
    
    func downloadHosts(shouldSave: Bool, searchString: String? = nil, completion: @escaping (Result<[Host], AppError>) -> ()) {
        createDataTaskRequest(url: API.Request.Hosts(searchString: searchString).encodedURL, completion: { (result) in
            switch result {
            case .Success(let data):
                do {
                    let hosts = try JSONDecoder().decode([Host].self, from: data)
                    completion(Result.Success(hosts))
                    
                    if shouldSave {
                        CoreDataHelper.saveHost(hosts: hosts)
                    }
                } catch {
                    completion(Result.Error(DataServiceError.decodingError(error)))
                }
                
            case .Error(let error):
                completion(Result.Error(error))
            }
        })
    }
    

    enum ImageSize: String {
        case full = ""
        case mini = "https://svampe.databasen.org/unsafe/175x175/"
    }
    
    func getImage(forUrl uri: String, size: ImageSize, completion: @escaping (UIImage, String) -> Void) {
        if let image = ELFileManager.getImage(withURL: uri) {
            completion(image, uri)
        } else if let image = imagesCache.object(forKey: NSString(string: "\(size.rawValue)\(uri)")) {
            completion(image, uri)
        } else if let image = imagesCache.object(forKey: NSString(string: "\(ImageSize.mini.rawValue)\(uri)")) {
            completion(image, uri)
            downloadImage(url: uri, imageSize: size, completion: completion)
        } else {
            downloadImage(url: uri, imageSize: size, completion: completion)
        }
    }
    
    private func downloadImage(url: String, imageSize: ImageSize, completion: @escaping (UIImage, String) -> Void) {
        var request = URLRequest(url: URL(string: "\(imageSize.rawValue)\(url)")!)
        request.timeoutInterval = 5
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = try? self.handleURLSession(data: data, response: response, error: error) else {return}
            guard let image = UIImage(data: data) else {return}
            self.imagesCache.setObject(image, forKey: NSString.init(string: "\(imageSize.rawValue)\(url)"))
                completion(image, url)
        }
        task.resume()
    }
    
    func getImagePredictions(image: UIImage, completion: @escaping (Result<[PredictionResult], AppError>) -> ()) {
        DispatchQueue.global(qos: .background).async {
             let parameters = ["instances": [["image_in": ["b64": image.rotate().toBase64()]]]] as [String : Any]
                   let data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            self.createDataTaskRequest(url: API.Post.imagePredict(speciesQueries: [.attributes(presentInDenmark: nil), .danishNames, .images(required: false), .redlistData, .statistics, .acceptedTaxon]).encodedURL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: nil) { (result) in
                       switch result {
                       case .Error(let error):
                           completion(Result.Error(error))
                       case .Success(let data):
                           do {
                               let predictionResults = try JSONDecoder().decode([PredictionResult].self, from: data)
                               completion(Result.Success(predictionResults))
                           } catch {
                               completion(Result.Error(DataServiceError.decodingError(error)))
                           }
                   }
               }
        }
}
}

