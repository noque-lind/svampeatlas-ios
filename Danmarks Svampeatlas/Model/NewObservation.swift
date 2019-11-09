//
//  NewObservation.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 09/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class NewObservation {
    
    enum Error {
        case noMushroom
        case noSubstrateGroup
        case noVegetationType
        case noLocality
        case noCoordinates
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
    public private(set) var images = [UIImage]()
    var predictionResultsState: TableViewState<PredictionResult> = .Empty
    
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
    
    func appendImage(image: UIImage) {
        if images.count == 0 && mushroom == nil {
            getPredictions(image: image)
        }
        
        images.append(image)
    }
    
    func removeImage(at: Int) {
        images.remove(at: at)
        
        if images.isEmpty {
            predictionResultsState = .Empty
            predictionsResultsStateChanged?()
        }
    }
    
    private func getPredictions(image: UIImage) {
        setPredictionResultsState(state: .Loading)
        
        DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .Error(let error):
                    self?.setPredictionResultsState(state: .Error(error, nil))
                case .Success(let predictionResults):
                    if case .Loading = self?.predictionResultsState  {
                        self?.setPredictionResultsState(state: .Items(predictionResults))
                    }
                }
            }
        }
    }
    
    private func setPredictionResultsState(state: TableViewState<PredictionResult>) {
        predictionResultsState = state
        predictionsResultsStateChanged?()
    }
    
    private func getDeterminationNotes(pickedMushroom: Mushroom) -> String {
        guard let predictionResult = predictionResultsState.currentItems().first(where: {$0.mushroom == pickedMushroom}) else {return ""}
        
        var string = "#imagevision_score: \(predictionResult.score.rounded(toPlaces: 2)) #imagevision_list: "
        
        predictionResultsState.currentItems().forEach { (predictionResult) in
            string += "\(predictionResult.mushroom.fullName) (\(predictionResult.score.rounded(toPlaces: 2))), "
        }
        
        return String(string.dropLast(2))
    }
    
    func returnAsDictionary(user: User) -> Result<[String: Any], Error> {
        guard let mushroom = mushroom  else {return Result.Error(Error.noMushroom)}
        guard let substrate = substrate else {return Result.Error(Error.noSubstrateGroup)}
        guard let vegetationType = vegetationType else {return Result.Error(Error.noVegetationType)}
        guard let locality = locality else {return Result.Error(Error.noLocality)}
        guard let observationCoordinate = observationCoordinate else {return Result.Error(Error.noCoordinates)}
        
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
        
        
        return Result.Success(dict)
    }
}
