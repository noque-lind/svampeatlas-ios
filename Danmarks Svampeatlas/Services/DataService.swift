//
//  DataService.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation
import ELKit

enum Result<ReturnValue, ErrorType> {
    case failure(ErrorType)
    case success(ReturnValue)

    func onSuccess(_ handler: (ReturnValue) -> Void) {
        switch self {
        case .success(let returnValue):
            handler(returnValue)
        case .failure: return
        }
    }

    func onFailure(_ handler: (ErrorType) -> Void) {
        switch self {
        case .success: return
        case .failure(let errorType):
            handler(errorType)
        }
    }
}

class DataService {

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

        var message: String {
            switch self {
            case .decodingError(let error):
                debugPrint(error)
                return NSLocalizedString("dataServiceError_decodingError_message", comment: "")
            case .searchReponseEmpty:
                return NSLocalizedString("dataServiceError_searchResponseEmpty_message", comment: "")
            case .loginError:
                return NSLocalizedString("dataServiceError_loginError_message", comment: "")
            case .empty:
                return NSLocalizedString("dataServiceError_empty_message", comment: "")
            default:
                return NSLocalizedString("dataServiceError_unknown_message", comment: "")
            }
        }

        var title: String {
            switch self {
            case .searchReponseEmpty:
                return NSLocalizedString("dataServiceError_searchResponseEmpty_title", comment: "")
            case .decodingError:
                return NSLocalizedString("dataServiceError_decodingError_title", comment: "")
            case .encodingError:
                return NSLocalizedString("dataServiceError_encodingError_title", comment: "")
            case .loginError:
                return NSLocalizedString("dataServiceError_loginError_title", comment: "")
            case .empty:
                return NSLocalizedString("dataServiceError_empty_title", comment: "")
            default:
                return NSLocalizedString("dataServiceError_unknown_title", comment: "")
            }
        }
    }

    enum URLSessionError: AppError {
        case noInternet
        case timeout
        case invalidResponse
        case serverError
        case unAuthorized
        case unknown(debugMessage: String)
        case payloadTooLarge
        var message: String {
            switch self {
            case .noInternet:
                return NSLocalizedString("urlSessionError_noInternet_message", comment: "")
            case .invalidResponse:
                return NSLocalizedString("urlSessionError_invalidResponse_message", comment: "")
            case .serverError:
                return NSLocalizedString("urlSessionError_serverError_message", comment: "")
            case .timeout:
                return NSLocalizedString("urlSessionError_timeout_message", comment: "")
            case .unknown(debugMessage: let message):
                return NSLocalizedString("urlSessionError_unknown_message", comment: "").appending(" : \(message)")
            case .unAuthorized:
                return NSLocalizedString("urlSessionError_unAuthorized_message", comment: "")
            case .payloadTooLarge:
                return NSLocalizedString("urlSessionError_payloadTooLarge_message", comment: "")
            }
        }

        var title: String {
            switch self {
            case .noInternet:
                return NSLocalizedString("urlSessionError_noInternet_title", comment: "")
            case .invalidResponse:
                return NSLocalizedString("urlSessionError_invalidResponse_title", comment: "")
            case .serverError:
                return NSLocalizedString("urlSessionError_serverError_title", comment: "")
            case .timeout:
                return NSLocalizedString("urlSessionError_timeout_title", comment: "")
            case .unknown:
                return NSLocalizedString("urlSessionError_unknown_title", comment: "")
            case .unAuthorized:
                return NSLocalizedString("urlSessionError_unAuthorized_title", comment: "")
            case .payloadTooLarge:
                return NSLocalizedString("urlSessionError_payloadTooLarge_title", comment: "")
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
    private var currentlyDownloading = [String: URLSessionTask]()

    lazy var observationsRepository = ObservationsData(ds: self)

    // CLASS FUNCTIONS

    internal func createDataTaskRequest(url: String, method: String = "GET", data: Data? = nil, contentType: String? = nil, contentLenght: Int? = nil, token: String? = nil, largeDownload: Bool = false, completion: @escaping (Result<Data, URLSessionError>) -> Void) {
        var request = URLRequest(url: URL.init(string: url)!)
        if !largeDownload {
            request.timeoutInterval = 20
        }

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
                completion(Result.success(data))
            } catch let error as URLSessionError {
                completion(Result.failure(error))
            } catch {
                completion(Result.failure(URLSessionError.unknown(debugMessage: String(data: data ?? Data(), encoding: .utf16) ?? "")))
            }
        }
        task.resume()
    }

    internal func handleURLSession(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
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
            return URLSessionError.unknown(debugMessage: "")
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
            return URLSessionError.unknown(debugMessage: "")
        }
    }
}

extension DataService {

    // FUNCTIONS THAT RETURN MUSHROOM/S

    func getMushrooms(searchString: String?, speciesQueries: [API.SpeciesQueries] = [API.SpeciesQueries.danishNames, API.SpeciesQueries.attributes(presentInDenmark: nil), API.SpeciesQueries.images(required: false), API.SpeciesQueries.statistics, API.SpeciesQueries.redlistData, .tag(id: 16)], limit: Int?, offset: Int = 0, largeDownload: Bool = false, useCache: Bool = true, completion: @escaping (Result<[Mushroom], AppError>) -> Void) {

        let api = API.Request.Mushrooms(searchString: searchString, speciesQueries: speciesQueries, limit: limit, offset: offset).encodedURL

        func handleData(data: Data) {
            do {

                                          let mushrooms = try JSONDecoder().decode([Mushroom].self, from: data)

                                          if searchString != nil && mushrooms.count == 0 {
                                              completion(Result.failure(DataServiceError.searchReponseEmpty))
                                          } else {
                                              completion(Result.success(mushrooms))
                                          }
                                      } catch {
                                          completion(Result.failure(DataServiceError.decodingError(error)))
                                      }
        }
        if useCache, let data = mushroomCache.object(forKey: NSString(string: api)) {
            handleData(data: Data(data))
        } else {
            createDataTaskRequest(url: api) { (result) in
                       switch result {
                       case .failure(let error):
                           completion(Result.failure(error))
                       case .success(let data):
                        handleData(data: data)
                       }
                   }
        }
    }

    func getMushroom(withID id: Int, completion: @escaping (Result<Mushroom, AppError>) -> Void) {
        createDataTaskRequest(url: API.Request.Mushroom(id: id).encodedURL) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let data):
                do {
                    guard let mushroom = try JSONDecoder().decode([Mushroom].self, from: data).first else {completion(Result.failure(DataServiceError.extractionError)); return}
                    completion(Result.success(mushroom))
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
                }
            }
        }
    }
}

extension DataService {

    // FUNCTIONS THAT RETURN OBSERVATION/S

    func getObservation(withID id: Int, completion: @escaping (Result<Observation, AppError>) -> Void) {
        createDataTaskRequest(url: API.observationWithIDURL(observationID: id)) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let data):
                do {
                    let observation = try JSONDecoder().decode(Observation.self, from: data)
                    completion(Result.success(observation))
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
                }
            }
        }
    }

    func getObservationsForMushroom(withID id: Int, limit: Int, offset: Int, completion: @escaping (Result<[Observation], AppError>) -> Void) {
        createDataTaskRequest(url: API.observationsURL(includeQueries: [.comments, .determinationView(taxonID: id), .geomNames, .images, .locality, .user(responseFilteredByUserID: nil)], limit: limit, offset: offset)) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let data):
                do {
                    let observations = try JSONDecoder().decode([Observation].self, from: data)
                    completion(Result.success(observations))
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
                }
            }
        }
    }

    func getObservationsWithin(geometry: API.Geometry, taxonID: Int? = nil, ageInYear: Int? = nil, completion: @escaping (Result<[Observation], AppError>) -> Void) {
        createDataTaskRequest(url: API.Request.Observations(geometry: geometry, ageInYear: ageInYear, include: [.comments, .determinationView(taxonID: taxonID), .geomNames, .images, .locality, .user(responseFilteredByUserID: nil)], limit: nil, offset: nil).encodedURL) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let data):
                do {
                    let observations = try JSONDecoder().decode([Observation].self, from: data)
                    completion(Result.success(observations))
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
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

    func getLocalitiesNearby(coordinates: CLLocationCoordinate2D, radius: API.Radius = API.Radius.smallest, completion: @escaping (Result<[Locality], AppError>) -> Void) {

        createDataTaskRequest(url: API.localitiesURL(coordinates: coordinates, radius: radius)) { (result) in
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let data):
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
                            case .hugest: if localities.count != 0 {completion(Result.success(localities)); return} else { newRadius = .country}
                            case .country: return
                            }

                            self.getLocalitiesNearby(coordinates: coordinates, radius: newRadius, completion: completion)
                        } else {
                            completion(Result.success(localities))
                        }
                    } else {
                        guard let geoName = (try JSONDecoder().decode(GeoNames.self, from: data)).geonames.first else {completion(Result.failure(DataServiceError.extractionError)); return}
                        completion(Result.success([Locality(id: geoName.geonameId, name: "\(geoName.name), \(geoName.countryCode)", latitude: Double(geoName.lat)!, longitude: Double(geoName.lng)!, geoName: geoName)]))
                    }
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
                }
            }
        }
    }

    func getSubstrateGroups(overrideOutdateError: Bool? = false, completion: @escaping (Result<[SubstrateGroup], AppError>) -> Void) {

    func sortAndComplete(substrateGroups: [SubstrateGroup]) {
        let sortedSubstrateGroups = substrateGroups.sorted(by: {$0.id < $1.id})
        completion(Result.success(sortedSubstrateGroups))
    }

    switch Database.instance.substrateGroupsRepository.fetchAll() {
    case .success(let substrateGroups): sortAndComplete(substrateGroups: substrateGroups)
    case .failure(let error):
        switch error {
        case .noEntries, .readError:
            downloadSubstrateGroups(completion: { (result) in
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let substrateGroups):
                    sortAndComplete(substrateGroups: substrateGroups)
                }
            })
        case .contentOutdated:
            downloadSubstrateGroups(completion: { (result) in
                switch result {
                case .success(let substrateGroups):
                    sortAndComplete(substrateGroups: substrateGroups)
                case .failure(_):
                    self.getSubstrateGroups(overrideOutdateError: true, completion: completion)
                    }
            })
        case .saveError, .initError: return
        }
    }
    }

    func downloadSubstrateGroups(completion: @escaping (Result<[SubstrateGroup], AppError>) -> Void) {
        createDataTaskRequest(url: API.substrateURL()) { (result) in
            switch result {
            case .success(let data):

                guard let JSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any]] else {completion(Result.failure(DataServiceError.extractionError)); return}

                var substrateGroups = [SubstrateGroup]()

                for object in JSON {
                    guard let hide = object["hide"] as? Bool, let id = object["_id"] as? Int, let name = object["name"] as? String, let name_uk = object["name_uk"] as? String, let group_dk = object["group_dk"] as? String, let group_uk = object["group_uk"] as? String, hide == false else {continue}

                    if let index = substrateGroups.firstIndex(where: {$0.dkName == group_dk}) {
                        substrateGroups[index].appendSubstrate(substrate: Substrate(id: id, dkName: name, enName: name_uk, czName: object["name_cz"] as? String))
                    } else {
                        substrateGroups.append(SubstrateGroup(dkName: group_dk, enName: group_uk, czName: object["group_cz"] as? String, substrates: [Substrate(id: id, dkName: name, enName: name_uk ,czName: object["name_cz"] as? String)]))
                    }
                }
                CoreDataHelper.saveSubstrateGroups(substrateGroups: substrateGroups)
                completion(Result.success(substrateGroups))

            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    func getVegetationTypes(overrideOutdateWarning: Bool? = false, completion: @escaping (Result<[VegetationType], AppError>) -> Void) {
        CoreDataHelper.fetchVegetationTypes(overrideOutdateWarning: overrideOutdateWarning, completion: { (result) in
            switch result {
            case .success(let vegetationTypes):
                let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                completion(Result.success(sortedVegetationTypes))
            case .failure(let coreDataError):
                switch coreDataError {
                case .noEntries, .readError:
                    downloadVegetationTypes(completion: { (result) in
                        switch result {
                        case .failure(let error):
                            completion(Result.failure(error))
                        case .success(let vegetationTypes):
                            let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                            completion(Result.success(sortedVegetationTypes))
                        }
                    })
                case .contentOutdated:
                    downloadVegetationTypes(completion: { (result) in
                        switch result {
                        case .success(let vegetationTypes):
                            let sortedVegetationTypes = vegetationTypes.sorted(by: {$0.id < $1.id})
                            completion(Result.success(sortedVegetationTypes))
                        case .failure(_):
                            self.getVegetationTypes(overrideOutdateWarning: true, completion: completion)
                        }
                    })
                case .saveError, .initError:
                    return
                }
            }
        })
    }

    func downloadVegetationTypes(completion: @escaping (Result<[VegetationType], AppError>) -> Void) {
        createDataTaskRequest(url: API.vegetationTypeURL(), completion: { (result) in
            switch result {
            case .success(let data):
                guard let JSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any]] else {completion(Result.failure(DataServiceError.extractionError)); return}

                var vegetationTypes = [VegetationType]()

                for object in JSON {
                    guard let id = object["_id"] as? Int, let name_uk = object["name_uk"] as? String, let name = object["name"] as? String else {continue}
                    vegetationTypes.append(VegetationType(id: id, dkName: name, enName: name_uk, czName: object["name_cz"] as? String))
                }
                completion(Result.success(vegetationTypes))
                CoreDataHelper.saveVegetationTypes(vegetationTypes: vegetationTypes)
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    func getPopularHosts(overrideOutdateWarning: Bool? = false, completion: @escaping (Result<[Host], AppError>) -> Void) {
        CoreDataHelper.fetchHosts(overrideOutdateWarning: overrideOutdateWarning) { (result) in
            switch result {
            case .success(let hosts):
                let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                completion(Result.success(sortedHosts))
            case .failure(let coreDataError):
                switch coreDataError {
                case .noEntries, .readError:
                    downloadHosts(shouldSave: true, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            completion(Result.failure(error))
                        case .success(let hosts):
                            let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                            completion(Result.success(sortedHosts))
                        }
                    })
                case .contentOutdated:
                    downloadHosts(shouldSave: true, completion: { (result) in
                        switch result {
                        case .failure(_):
                            self.getPopularHosts(overrideOutdateWarning: true, completion: completion)
                        case .success(let hosts):
                            let sortedHosts = hosts.sorted(by: {$0.probability > $1.probability})
                            completion(Result.success(sortedHosts))
                        }
                    })
                case .saveError, .initError: return
                }
            }
        }
    }

    func downloadHosts(shouldSave: Bool, searchString: String? = nil, completion: @escaping (Result<[Host], AppError>) -> Void) {
        createDataTaskRequest(url: API.Request.Hosts(searchString: searchString).encodedURL, completion: { (result) in
            switch result {
            case .success(let data):
                do {
                    let hosts = try JSONDecoder().decode([Host].self, from: data)
                    completion(Result.success(hosts))

                    if shouldSave {
                        CoreDataHelper.saveHost(hosts: hosts)
                    }
                } catch {
                    completion(Result.failure(DataServiceError.decodingError(error)))
                }

            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    

    enum ImageSize: String {
        case full = ""
        case mini = "https://svampe.databasen.org/unsafe/175x175/"
    }

    func getImage(forUrl uri: String, size: ImageSize, completion: @escaping (UIImage, String) -> Void) {
        if let image = ELFileManager.getMushroomImage(withURL: uri) {
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

    func getImagePredictions(image: UIImage, completion: @escaping (Result<[PredictionResult], AppError>) -> Void) {
        DispatchQueue.global(qos: .default).async {
             let parameters = ["instances": [["image_in": ["b64": image.rotate().toBase64()]]]] as [String : Any]
                   let data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            self.createDataTaskRequest(url: API.Post.imagePredict(speciesQueries: [.attributes(presentInDenmark: nil), .danishNames, .images(required: false), .redlistData, .statistics, .acceptedTaxon]).encodedURL, method: "POST", data: data, contentType: "application/json", contentLenght: nil, token: nil) { (result) in
                       switch result {
                       case .failure(let error):
                           completion(Result.failure(error))
                       case .success(let data):
                           do {
                               let predictionResults = try JSONDecoder().decode([PredictionResult].self, from: data)
                               completion(Result.success(predictionResults))
                           } catch {
                               completion(Result.failure(DataServiceError.decodingError(error)))
                           }
                   }
               }
        }
}
}

