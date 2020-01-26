//
//  NewObservation.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 09/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit
import ImageIO

class NewObservation {
    
    enum Error: AppError {
        
        var recoveryAction: RecoveryAction? {
            return nil
        }
        
        
        case noMushroom
        case noSubstrateGroup
        case noVegetationType
        case noLocality
        case noCoordinates
       
        var errorTitle: String {
            switch self {
            case .noSubstrateGroup, .noVegetationType, .noMushroom: return NSLocalizedString("newObservationError_missingInformation", comment: "")
            case .noLocality: return NSLocalizedString("newObservationError_noLocality_title", comment: "")
            case .noCoordinates: return NSLocalizedString("newObservationError_noCoordinates_title", comment: "")
            }
        }
        
        var errorDescription: String {
            switch self {
            case .noMushroom: return NSLocalizedString("newObservationError_noMushroom_message", comment: "")
            case .noSubstrateGroup: return NSLocalizedString("newObservationError_noSubstrateGroup_message", comment: "")
            case .noVegetationType: return NSLocalizedString("newObservationError_noVegetationType_message", comment: "")
            case .noCoordinates: return NSLocalizedString("newObservationError_noCoordinates_message", comment: "")
            case .noLocality: return NSLocalizedString("newObservationError_noLocality_message", comment: "")
            }
        }
    }
    
    enum DeterminationConfidence: String, CaseIterable {
        case confident = "sikker"
        case likely = "sandsynlig"
        case possible = "mulig"
    }
    
    var observationDate: Date
    var observationDateAccuracy = "day"
    var substrate: Substrate?
    var vegetationType: VegetationType?
    var hosts = [Host]()
    var lockedHosts = false
    var ecologyNote: String?
    var mushroom: Mushroom?
    var determinationConfidence: DeterminationConfidence = .confident
    var note: String?
    var observationCoordinate: CLLocation?
    var user: User?
    var locality: Locality?
    public private(set) var images = [URL]()
    var predictionResultsState: Section<PredictionResult>.State = .empty {
        didSet {
            predictionsResultsStateChanged?()
        }
    }
    
    var predictionsResultsStateChanged: (() -> ())?
    
    init() {
        self.observationDate = Date()
        
        if let substrateID = UserDefaultsHelper.defaultSubstrateID {
            self.substrate = CoreDataHelper.fetchSubstrateGroup(withID: substrateID)
            self.substrate?.isLocked = true
        }
        
        if let vegetationTypeID = UserDefaultsHelper.defaultVegetationTypeID {
            self.vegetationType = CoreDataHelper.fetchVegetationType(withID: vegetationTypeID)
            self.vegetationType?.isLocked = true
        }
        
        if let hostsIDS = UserDefaultsHelper.defaultHostsIDS {
            self.hosts = hostsIDS.compactMap({CoreDataHelper.fetchHost(withID: $0)})
            self.lockedHosts = true
        }
    }
    
    func appendImage(imageURL: URL) {
        if images.count == 0 && mushroom == nil {
            getPredictions(imageURL: imageURL)
        }
        
        images.append(imageURL)
    }
    
    func removeImage(imageURL: URL) {
        ELFileManager.deleteImage(imageURL: imageURL)
        
        guard let index = images.firstIndex(of: imageURL) else {return}
        images.remove(at: index)
        
        if images.isEmpty {
            predictionResultsState = .empty
        }
    }
    
    private func getPredictions(imageURL: URL) {
        guard let image = UIImage(url: imageURL) else {return}
        predictionResultsState = .loading
        DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.predictionResultsState = .error(error: error, handler: nil)
                case .success(let predictionResults):
                    self?.predictionResultsState = .items(items: predictionResults)
                }
            }
        }
    }
    
    func returnImageLocationIfNecessary(location: CLLocation) -> CLLocation? {
        guard let firstImageURL = images.first, let imageLocation = extractExifLocation(imageURL: firstImageURL) else {return nil}
        
        if imageLocation.distance(from: location) > 500 {
            return imageLocation
        } else {
            return nil
        }
    }
    
    func returnImageLocationIfNecessary(imageURL: URL) -> CLLocation? {
        guard let imageLocation = extractExifLocation(imageURL: imageURL) else {return nil}
        
        if let currentLocation = observationCoordinate {
            if imageLocation.distance(from: currentLocation) > 500 {
                return imageLocation
            } else {
                return nil
            }
        } else {
            return imageLocation
        }
    }
    
    func extractExifLocation(imageURL: URL) -> CLLocation? {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil)else {return nil}
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else { return nil }
        guard let gpsDict = imageProperties[String(kCGImagePropertyGPSDictionary)] as? [String: Any] else { return nil }
        guard var latitude = gpsDict[String(kCGImagePropertyGPSLatitude)] as? Double, var longitude = gpsDict[String(kCGImagePropertyGPSLongitude)] as? Double else {return nil}
        let altitude = (gpsDict[String(kCGImagePropertyGPSAltitude)] as? Double) ?? -1
        let accuracy = (gpsDict[String(kCGImagePropertyGPSDOP)] as? Double) ?? -1
        let latitudeRef = (gpsDict[String(kCGImagePropertyGPSLatitudeRef)] as? String)
        let longitudeRef = (gpsDict[String(kCGImagePropertyGPSLongitudeRef)] as? String)
        
        var timeStamp: Date?
        if let exif = (imageProperties[String(kCGImagePropertyExifDictionary)] as? [String: Any]), let timeStampDate = (exif[String(kCGImagePropertyExifDateTimeOriginal)] as? String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current
            timeStamp = dateFormatter.date(from: timeStampDate)
        }
        if latitudeRef == "S" {
            latitude = -latitude
        }
        
        if longitudeRef == "W" {
            longitude = -longitude
        }
      
       return CLLocation.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: accuracy, verticalAccuracy: accuracy, timestamp: timeStamp ?? Date())
    }

    
    private func getDeterminationNotes(pickedMushroom: Mushroom) -> String {
        guard case Section<PredictionResult>.State.items(items: let predictionResults) = predictionResultsState, let predictionResult = predictionResults.first(where: {$0.mushroom == pickedMushroom}) else {return ""}
            
        var string = "#imagevision_score: \(predictionResult.score.rounded(toPlaces: 2)) #imagevision_list: "
        
        predictionResults.forEach({
            string += "\($0.mushroom.fullName) (\($0.score.rounded(toPlaces: 2))), "
        })
        
        return String(string.dropLast(2))
    }
    
    func returnAsDictionary(user: User) -> Result<[String: Any], Error> {
        guard let mushroom = mushroom  else {return Result.failure(Error.noMushroom)}
        guard let substrate = substrate else {return Result.failure(Error.noSubstrateGroup)}
        guard let vegetationType = vegetationType else {return Result.failure(Error.noVegetationType)}
        guard let locality = locality else {return Result.failure(Error.noLocality)}
        guard let observationCoordinate = observationCoordinate else {return Result.failure(Error.noCoordinates)}
        
        var dict: [String: Any] = ["observationDate": observationDate.convert(into: "yyyy-MM-dd")]
        dict["os"] = "iOS"
        dict["browser"] = "Native App"
        dict["substrate_id"] = substrate.id
        dict["vegetationtype_id"] = vegetationType.id
        dict["decimalLatitude"] = observationCoordinate.coordinate.latitude
        dict["decimalLongitude"] = observationCoordinate.coordinate.longitude
        dict["accuracy"] = observationCoordinate.horizontalAccuracy
        dict["users"] = [["_id": user.id, "Initialer": user.initials, "email": user.email, "facebook": user.facebookID ?? "", "name": user.name]]
        dict["determination"] = ["confidence": determinationConfidence.rawValue, "taxon_id": mushroom.id, "user_id": user.id, "notes": getDeterminationNotes(pickedMushroom: mushroom)]
        
        if let ecologyNote = ecologyNote {
            dict["ecologynote"] = ecologyNote
        }
        
        if let note = note {
            dict["note"] = note
        }
        
        if hosts.count > 0 {
            var hostArray = [[String: Any]]()
            
            for host in hosts {
                hostArray.append(["_id": host.id])
            }
            
            dict["associatedOrganisms"] = hostArray
        }
        
        if let geoName = locality.geoName {
            dict["geonameId"] = geoName.geonameId
            dict["geoname"] = ["geonameId": geoName.geonameId, "name": geoName.name, "adminName1": geoName.adminName1, "lat": geoName.lat, "lng": geoName.lng, "countryName": geoName.countryName, "countryCode": geoName.countryCode, "fcodeName": geoName.fcodeName, "fclName": geoName.fclName]
        } else {
            dict["locality_id"] = locality.id
        }
        
        
        return Result.success(dict)
    }
    
    deinit {
        images.forEach({ELFileManager.deleteImage(imageURL: $0)})
    }
}
