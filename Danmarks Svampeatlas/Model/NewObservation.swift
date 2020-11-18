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
import ELKit

class AddObservationViewModel:NSObject {
    
    enum Error: AppError {
        
        var recoveryAction: RecoveryAction? {
            return nil
        }
        
        case noMushroom
        case noSubstrateGroup
        case noVegetationType
        case noLocality
        case noCoordinates
        case lowAccuracy(accurracy: Double)
        
        var title: String {
            switch self {
            case .noSubstrateGroup, .noVegetationType, .noMushroom: return NSLocalizedString("newObservationError_missingInformation", comment: "")
            case .noLocality: return NSLocalizedString("newObservationError_noLocality_title", comment: "")
            case .noCoordinates: return NSLocalizedString("newObservationError_noCoordinates_title", comment: "")
            case .lowAccuracy: return NSLocalizedString("Low accuracy", comment: "")
            }
        }
        
        var message: String {
            switch self {
            case .noMushroom: return NSLocalizedString("newObservationError_noMushroom_message", comment: "")
            case .noSubstrateGroup: return NSLocalizedString("newObservationError_noSubstrateGroup_message", comment: "")
            case .noVegetationType: return NSLocalizedString("newObservationError_noVegetationType_message", comment: "")
            case .noCoordinates: return NSLocalizedString("newObservationError_noCoordinates_message", comment: "")
            case .noLocality: return NSLocalizedString("newObservationError_noLocality_message", comment: "")
            case .lowAccuracy(let accurracy): return String(format: NSLocalizedString("The location accurracy is: %0.2f m, which is too imprecise. Would you like to use your current location instead?", comment: ""), accurracy.rounded(toPlaces: 2))
            }
        }
    }
    
    enum Notification {
        case newObservationError(error: Error)
        case error(error: AppError)
        case localityError(error: AppError?)
        case foundLocationAndLocality(observationLocation: CLLocation, locality: Locality)
        case useImageMetadata(precision: Double)
        case successfullUpload(id: Int)
        case uploadWithError(message: String)
        case editCompleted(id: Int)
        case editWithError(message: String)
        
        var title: String {
            switch self {
            case .editWithError:
                return NSLocalizedString("The observation was successfully edited", comment: "")
            case .editCompleted:
                return NSLocalizedString("The observation was successfully edited", comment: "")
            case .uploadWithError:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .successfullUpload:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .newObservationError(error: let error):
                return error.title
            case .error(error: let error): return error.title
            case .useImageMetadata: return NSLocalizedString("addObservationVC_useImageMetadata_title", comment: "")
            case .localityError:
                return NSLocalizedString("addObservationVC_localityFoundError_title", comment: "")
            case .foundLocationAndLocality:
                return NSLocalizedString("addObservationVC_localityFound_title", comment: "")
            }
        }
        
        var message: String {
            switch self {
            case .editWithError(message: let message):
                return message
            case .editCompleted(id: let id):
                return "DMS: \(id)"
            case .uploadWithError(message: let message):
                return message
            case .successfullUpload(id: let id):
                return "DMS: \(id)"
            case .newObservationError(error: let error):
                return error.message
            case .error(error: let error): return error.message
            case .useImageMetadata(precision: let precision):
                return String(format: NSLocalizedString("addObservationVC_useImageMetadata_message", comment:""), "\(precision.rounded(toPlaces: 2))")
            case .localityError(error: let error):
                return error?.message ?? ""
            case .foundLocationAndLocality(observationLocation: let observationLocation, locality: let locality):
                return String.localizedStringWithFormat(NSLocalizedString("addObservationVC_localityFound_message", comment: ""), locality.name, observationLocation.coordinate.longitude.rounded(toPlaces: 2), observationLocation.coordinate.latitude.rounded(toPlaces: 2), observationLocation.horizontalAccuracy.rounded(toPlaces: 2))
            }
        }
    }
    
    let session: Session
    let action: AddObservationVC.Action
    
    enum DeterminationConfidence: String, CaseIterable {
        case certain = "sikker"
        case likely = "sandsynlig"
        case possible = "mulig"
    }
    
    
    var observationDate = Date()
    var observationDateAccuracy = "day"
    var substrate: Substrate?
    var vegetationType: VegetationType?
    var hosts = [Host]()
    var lockedHosts = false
    var ecologyNote: String?
    var mushroom: Mushroom?
    var determinationConfidence: DeterminationConfidence = .certain
    var note: String?
    
    
    let images = ELListener<[NewObservationImage]>.init([])
    let predictionResults = ELListener<Section<PredictionResult>.State>.init(.empty)
    
    let observationLocation = ELListener<SimpleState<CLLocation>>.init(.empty)
    let localities = ELListener<SimpleState<[Locality]>>.init(.empty)
    
    let uploadState = ELListener<SimpleState<Void>>.init(.empty)
    let setupState = ELListener<SimpleState<Void>>.init(.empty)
    
    
    let locality = ELListener<Locality?>.init(nil)
    
    let addedImage = ELEvent<NewObservationImage>.init()
    let removedImage = ELEvent<Int>.init()
    
    let showNotification = ELEvent<(Notification, ELNotificationView.Style)>.init()
    
    init(action: AddObservationVC.Action, session: Session) {
        self.action = action
        self.session = session
        super.init()
        self.start(action: action)
    }
    
    private lazy var locationManager: LocationManager = {
        let manager = LocationManager.init(accuracy: .high)
        manager.state.observe(listener: { [weak self, weak manager] state in
            switch state {
            case .locating:
                self?.observationLocation.set(.loading)
            case .error(error: let error):
                self?.observationLocation.set(.error(error: error, handler: { (recoveryAction) in
                    switch recoveryAction {
                    case .openSettings: UIApplication.openSettings()
                    default: manager?.start()
                    }
                }))
            case .foundLocation(location: let location):
                if let imageLocation = self?.images.value.first?.url.getExifLocation(), location.distance(from: imageLocation) > imageLocation.horizontalAccuracy {
                    self?.showNotification.post(value:
                                                    (Notification.useImageMetadata(precision: imageLocation.horizontalAccuracy),
                                                     .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
                                                                .positive(NSLocalizedString("addObservationVC_useImageMetadata_positive", comment: ""), { [weak self] in
                                                                    self?.observationLocation.set(.items(item: imageLocation))
                                                                    self?.observationDate = imageLocation.timestamp
                                                                    self?.setupState.set(.items(item: ()))
                                                                    self?.findLocality(location: imageLocation)
                                                                }),
                                                                .negative(   NSLocalizedString("addObservationVC_useImageMetadata_negative", comment: ""), { [weak self] in
                                                                    self?.observationLocation.set(.items(item: location))
                                                                    self?.findLocality(location: location)
                                                                })])))
                    
                } else {
                    self?.observationLocation.set(.items(item: location))
                    self?.findLocality(location: location)
                }
            default: return
            }
        })
        return manager
    }()
    
    
    func start(action: AddObservationVC.Action) {
        switch action {
        case .new:
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
            setupState.set(.items(item: ()))
            locationManager.start()
        case .edit(observationID: let id):
            setupState.set(.loading)
            DataService.instance.getObservation(withID: id) { [weak self] (result) in
                Spinner.stop()
                switch result {
                case .failure(let error):
                    self?.setupState.set(.error(error: error, handler: nil))
                case .success(let observation):
                    self?.do({
                        $0.mushroom = Mushroom(id: observation.determination.id, fullName: observation.determination.fullName)
                        $0.substrate = observation.substrate
                        $0.vegetationType = observation.vegetationType
                        $0.ecologyNote = observation.ecologyNote
                        $0.note = observation.note
                        $0.hosts = observation.hosts
                        
                        if let dateString = observation.observationDate, let date = Date(ISO8601String: dateString) {
                            $0.observationDate = date
                        } else {
                            $0.observationDate = Date()
                        }
                        
                        $0.observationLocation.set(.items(item: observation.location))
                        $0.locality.set(observation.locality)
                        if let locality = observation.locality {
                            $0.localities.set(.items(item: [locality]))
                        }
                        
                        if let images = observation.images {
                            let observationImages: [NewObservationImage] = images.compactMap({
                                                                                                guard let url = URL(string: $0.url), let createdDate = $0.createdDate else {return nil}
                                                                                                return NewObservationImage(type: .uploaded(id: $0.id, creationDate: Date(ISO8601String: createdDate), userIsValidator: self?.session.user.isValidator ?? false), url: url)})
                            $0.images.set(observationImages)
                        }
                        
                    })
                    self?.setupState.set(.items(item: ()))
                }
            }
            
        }
    }
    
    func reset() {
        observationDate = Date()
        ecologyNote = nil
        mushroom = nil
        determinationConfidence = .certain
        note = nil
        images.set([])
        predictionResults.set(.empty)
        observationLocation.set(.empty)
        localities.set(.empty)
        uploadState.set(.empty)
        locality.set(nil)
        start(action: .new)
    }
    
    func addImage(newObservationImage: NewObservationImage) {
        if images.value.count == 0 && mushroom == nil {
            getPredictions(imageURL: newObservationImage.url)
        }
        
        images.value.append(newObservationImage)
        addedImage.post(value: newObservationImage)
        if let imageLocation = newObservationImage.url.getExifLocation(), let currentObservationLocation = observationLocation.value.item, currentObservationLocation.distance(from: imageLocation) > imageLocation.horizontalAccuracy {
            showNotification.post(value: (Notification.useImageMetadata(precision: imageLocation.horizontalAccuracy),
                                          .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
                                                    .positive(NSLocalizedString("addObservationVC_useImageMetadata_positive", comment: ""), { [weak self] in
                                                        self?.observationLocation.set(.items(item: imageLocation))
                                                        self?.observationDate = imageLocation.timestamp
                                                        self?.setupState.set(.items(item: ()))
                                                        self?.findLocality(location: imageLocation)
                                                    }),
                                                    .negative(NSLocalizedString("addObservationVC_useImageMetadata_negative", comment: ""), {})])))
        }
    }
    
    func removeImage(newObservationImage: NewObservationImage) {
        switch newObservationImage.type {
        case .new:
            ELFileManager.deleteImage(imageURL: newObservationImage.url)
            guard let index = images.value.firstIndex(where: {$0.url == newObservationImage.url}) else {return}
            images.value.remove(at: index)
            removedImage.post(value: index)
        case .uploaded(id: let id, _, _):
            session.deleteImage(id: id) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    self?.images.set(self?.images.value ?? [])
                    self?.showNotification.post(value: (Notification.error(error: error), .error(actions: nil)))
                case .success:
                    guard let index = self?.images.value.firstIndex(where: {$0.url == newObservationImage.url}) else {return}
                    self?.images.value.remove(at: index)
                    self?.removedImage.post(value: index)
                }
            }
        }
        
        if images.value.isEmpty {
            predictionResults.set(.empty)
        }
    }
    
    private func findLocality(location: CLLocation) {
        localities.set(.loading)
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { [weak self] result in
            switch result {
            case .success(let localities):
                self?.localities.set(.items(item: localities))
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if let closest = closest {
                    self?.locality.set(closest)
                    self?.showNotification.post(value: (Notification.foundLocationAndLocality(observationLocation: location, locality: closest),
                                                        .success))
                } else {
                    self?.showNotification.post(value: (.localityError(error: nil), .error(actions: nil)))
                }
            case .failure(let error):
                self?.localities.set(.error(error: error, handler: nil))
                self?.showNotification.post(value: (.localityError(error: error), .error(actions: nil)))
            }
        }
    }
    
    private func getPredictions(imageURL: URL) {
        guard let image = UIImage(url: imageURL) else {return}
        predictionResults.set(.loading)
        DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.predictionResults.set(.error(error: error, handler: nil))
            case .success(let predictionResults):
                self?.predictionResults.set(.items(items: predictionResults))
            }
        }
    }
    
    func uploadObservation(action: AddObservationVC.Action) {
        func handleDictError(error: Error) {
            switch error {
            case .lowAccuracy:
                showNotification.post(value: (Notification.newObservationError(error: error), ELNotificationView.Style.action(backgroundColor: .appSecondaryColour(), actions: [
                                                                                                                                .positive(NSLocalizedString("Yes, find my location", comment: ""), { [weak self] in
                                                                                                                                    self?.locationManager.start()
                                                                                                                                }),
                                                                                                                                .negative(NSLocalizedString("No, I'll adjust it myself", comment: ""), {})])))
            default: showNotification.post(value: (Notification.newObservationError(error: error), ELNotificationView.Style.error(actions: nil)))
            }
            
        }
        
        switch action {
        case .new:
            switch returnAsDictionary(overrideLowAccuracy: false, isEdit: false) {
            case .failure(let error):
                handleDictError(error: error)
            case .success(let dict):
                uploadState.set(.loading)
                session.uploadObservation(dict: dict, imageURLs: images.value.map({$0.url})) { [weak self] (result) in
                    switch result {
                    case .failure(let error):
                        self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
                    case .success(let data):
                        if data.uploadedImagesCount == self?.images.value.count {
                            self?.showNotification.post(value: (Notification.successfullUpload(id: data.observationID), ELNotificationView.Style.success))
                        } else {
                            self?.showNotification.post(value: (Notification.uploadWithError(message: String(format: NSLocalizedString("Although an error occured uploading the image/s. %d out of %d images has been successfully uploaded", comment: ""), data.uploadedImagesCount, self?.images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                        }
                    }
                }
            }
        case .edit(observationID: let id):
            switch returnAsDictionary(overrideLowAccuracy: false, isEdit: true) {
            case .failure(let error):
                handleDictError(error: error)
            case .success(let dict):
                uploadState.set(.loading)
                let newImages = images.value.compactMap({$0.type == .new ? $0.url: nil})
                session.editObservation(id: id, dict: dict, newImageURLs: newImages) { [weak self] (result) in
                    switch result {
                    case .failure(let error):
                        self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
                    case .success(let data):
                        if data.uploadedImagesCount == newImages.count {
                            self?.showNotification.post(value: (Notification.editCompleted(id: data.observationID), ELNotificationView.Style.success))
                        } else {
                            self?.showNotification.post(value: (Notification.editWithError(message: String(format: NSLocalizedString("Although an error occured uploading the image/s. %d out of %d images has been successfully uploaded", comment: ""), data.uploadedImagesCount, self?.images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                        }
                    }
                }
            }
        }
        
        
    }
    
    private func returnAsDictionary(overrideLowAccuracy: Bool, isEdit: Bool) -> Result<[String: Any], Error> {
        func getDeterminationNotes(pickedMushroom: Mushroom) -> String {
            guard case Section<PredictionResult>.State.items(items: let predictionResults) = predictionResults.value, let predictionResult = predictionResults.first(where: {$0.mushroom.id == pickedMushroom.id}) else {return ""}
            var string = "#imagevision_score: \(predictionResult.score.rounded(toPlaces: 2)) #imagevision_list: "
            
            predictionResults.forEach({
                string += "\($0.mushroom.fullName) (\($0.score.rounded(toPlaces: 2))), "
            })
            
            return String(string.dropLast(2))
        }
        
        guard let substrate = substrate else {return Result.failure(Error.noSubstrateGroup)}
        guard let vegetationType = vegetationType else {return Result.failure(Error.noVegetationType)}
        guard let locality = locality.value else {return Result.failure(Error.noLocality)}
        guard let observationCoordinate = observationLocation.value.item else {return Result.failure(Error.noCoordinates)}
        if !overrideLowAccuracy {
            guard observationCoordinate.horizontalAccuracy <= 500 else {return Result.failure(Error.lowAccuracy(accurracy: observationCoordinate.horizontalAccuracy))}
        }
        
        var dict: [String: Any] = [:]
        dict["observationDate"] = observationDate.convert(into: "yyyy-MM-dd")
        dict["os"] = "iOS"
        dict["browser"] = "Native App"
        dict["substrate_id"] = substrate.id
        dict["vegetationtype_id"] = vegetationType.id
        dict["decimalLatitude"] = observationCoordinate.coordinate.latitude
        dict["decimalLongitude"] = observationCoordinate.coordinate.longitude
        dict["accuracy"] = observationCoordinate.horizontalAccuracy
        
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
        
        dict["users"] = [["_id": session.user.id, "Initialer": session.user.initials, "email": session.user.email, "facebook": session.user.facebookID ?? "", "name": session.user.name]]
        
        if let geoName = locality.geoName {
            dict["geonameId"] = geoName.geonameId
            dict["geoname"] = ["geonameId": geoName.geonameId, "name": geoName.name, "adminName1": geoName.adminName1, "lat": geoName.lat, "lng": geoName.lng, "countryName": geoName.countryName, "countryCode": geoName.countryCode, "fcodeName": geoName.fcodeName, "fclName": geoName.fclName]
        } else {
            dict["locality_id"] = locality.id
        }
        
        if !isEdit {
            guard let mushroom = mushroom  else {return Result.failure(Error.noMushroom)}
            
            dict["determination"] = ["confidence": determinationConfidence.rawValue, "taxon_id": mushroom.id, "user_id": session.user.id, "notes": getDeterminationNotes(pickedMushroom: mushroom)]
            
            
        }
        
        return Result.success(dict)
    }
    
    func setCustomLocation(location: CLLocation) {
        observationLocation.set(.items(item: location))
        findLocality(location: location)
    }
    
    func refindLocation() {
        locationManager.start()
    }
}

struct NewObservationImage {
    
    enum `Type`: Equatable {
        case new
        case uploaded(id: Int, creationDate: Date?, userIsValidator: Bool)
    }
    
    public private(set) var type: Type
    public private (set) var url: URL
    
    var isDeletable: Bool {
        switch type {
        case .new: return true
        case .uploaded(id: _, creationDate: let date, userIsValidator: let userIsValidator):
            guard userIsValidator == false else {return true}
            guard let date = date, let days = NSCalendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: date, to: Date()).day else {return false}
            return days > 7 ? false: true
        }
    }
}
