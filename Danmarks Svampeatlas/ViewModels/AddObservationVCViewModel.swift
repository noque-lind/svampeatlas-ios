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
import Then

class AddObservationViewModel:NSObject {
    
    enum Notification {
        case userObservationValidationError(error: UserObservation.ValidationError)
        case error(error: AppError)
        case localityError(error: AppError?)
        case foundLocationAndLocality(observationLocation: CLLocation, locality: Locality)
        case useImageMetadata(precision: Double)
        case successfullUpload(id: Int)
        case uploadWithError(message: String)
        case editCompleted(id: Int)
        case deleteSuccesful
        case noteSave
        case editWithError(message: String)
        
        var title: String {
            switch self {
            case .deleteSuccesful:
                return ""
            case .editWithError:
                return NSLocalizedString("The observation was successfully edited", comment: "")
            case .editCompleted:
                return NSLocalizedString("The observation was successfully edited", comment: "")
            case .noteSave:
                return NSLocalizedString("The note is saved", comment: "")
            case .uploadWithError:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .successfullUpload:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .userObservationValidationError(error: let error):
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
            case .deleteSuccesful: return ""
            case .noteSave:
                return NSLocalizedString("The note has been saved in local storage, you can see it in your notebook", comment: "")
            case .editWithError(message: let message):
                return message
            case .editCompleted(id: let id):
                return "DMS: \(id)"
            case .uploadWithError(message: let message):
                return message
            case .successfullUpload(id: let id):
                return "DMS: \(id)"
            case .userObservationValidationError(error: let error):
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
   
    private var userObservation: UserObservation = UserObservation() {
        didSet {
            if userObservation.observationLocation?.item != self.observationLocation.value?.item?.item {
                if let observationLocation = userObservation.observationLocation {
                    _observationLocation.set(.items(item: observationLocation))
                } else {
                    _observationLocation.set(.empty)
                }
            }
            
            if userObservation.locality?.locality != self.locality.value?.locality {
                if let locality = userObservation.locality {
                    _locality.set(locality)
                    _localities.set(.items(item: [locality.locality]))
                } else {
                    _locality.set(nil)
                    _localities.set(.empty)
                }
            }
           
            if userObservation.images != self.images.value {
                _images.set(userObservation.images)
            }
        }
    }
    
    var mushroom: Mushroom? {
        get {
            return userObservation.mushroom
        }
        set {
            userObservation.mushroom = newValue
            guard let mushroom = newValue, case Section<PredictionResult>.State.items(items: let predictionResults) = _predictionResults.value, let predictionResult = predictionResults.first(where: {$0.mushroom.id == mushroom.id}) else {userObservation.determinationNotes = nil; return}
                var string = "#imagevision_score: \(predictionResult.score.rounded(toPlaces: 2)) #imagevision_list: "
                predictionResults.forEach({
                    string += "\($0.mushroom.fullName) (\($0.score.rounded(toPlaces: 2))), "
                })
            userObservation.determinationNotes = String(string.dropLast(2))
        }
    }
    
    var determinationConfidence: UserObservation.DeterminationConfidence {
        get {
            return userObservation.determinationConfidence
        }
        set {
            userObservation.determinationConfidence = newValue
        }
    }
    
    var observationDate: Date {
        get {
            return userObservation.observationDate
        }
        set {
            userObservation.observationDate = newValue
        }
      }
    
    var vegetationType: VegetationType? {
        get {
            return userObservation.vegetationType
        }
        set {
            userObservation.vegetationType = newValue
        }
    }
    
    var substrate: Substrate? {
        get {
            return userObservation.substrate
        }
        set {
            userObservation.substrate = newValue
        }
    }
    
    var hosts: [Host] {
        get {
            return userObservation.hosts
        }
        set {
            userObservation.hosts = newValue
        }
    }
    
    var lockedHosts = false
    
    var note: String? {
        get {
            return userObservation.note
        }
        set {
            userObservation.note = newValue
        }
    }
    
    var ecologyNote: String? {
        get {
            return userObservation.ecologyNote
        }
        set {
            userObservation.ecologyNote = newValue
        }
    }
    
    private lazy var _images = ELListener<[UserObservation.Image]>.init([]) { [weak self] value in
        self?.userObservation.images = value
    }
    lazy var images = ELListenerImmutable(_images)
    
    private lazy var _locality = ELListener<(locality: Locality, locked: Bool)?>.init(nil) { [weak self] value in
        self?.userObservation.locality = value
        UserDefaultsHelper.lockedLocality = (value?.locked ?? false) ? value?.locality: nil
    }
    lazy var locality = ELListenerImmutable(_locality)
    
    private  lazy var _observationLocation = ELListener<SimpleState<(item: CLLocation, locked: Bool)>?>.init(nil) { [weak self] value in
        self?.userObservation.observationLocation = value?.item
        UserDefaultsHelper.lockedLocation = (value?.item?.locked ?? false) ? value?.item?.item: nil
    }
    lazy var observationLocation = ELListenerImmutable(_observationLocation)
    
    private let _localities = ELListener<SimpleState<[Locality]>>.init(.empty)
    lazy var localities = ELListenerImmutable(_localities)

    private let _predictionResults = ELListener<Section<PredictionResult>.State>.init(.empty)
    lazy var predictionResults = ELListenerImmutable(_predictionResults)
    
    let uploadState = ELListener<SimpleState<Void>>.init(.empty)
    let setupState = ELListener<SimpleState<Void>>.init(.empty)
    
    
    let addedImage = ELEvent<UserObservation.Image>.init()
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
                self?._observationLocation.set(.loading)
            case .error(error: let error):
                self?._observationLocation.set(.error(error: error, handler: { (recoveryAction) in
                    switch recoveryAction {
                    case .openSettings: UIApplication.openSettings()
                    default: manager?.start()
                    }
                }))
            case .foundLocation(location: let location):
                if let imageLocation = self?._images.value.first?.url.getExifLocation(), location.distance(from: imageLocation) > imageLocation.horizontalAccuracy {
                    self?.showNotification.post(value:
                                                    (Notification.useImageMetadata(precision: imageLocation.horizontalAccuracy),
                                                     .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
                                                        .positive(NSLocalizedString("addObservationVC_useImageMetadata_positive", comment: ""), { [weak self] in
                                                            self?._observationLocation.set(.items(item: (imageLocation, false)))
                                                            self?.observationDate = imageLocation.timestamp
                                                            self?.setupState.set(.items(item: ()))
                                                            self?.findLocality(location: imageLocation)
                                                        }),
                                                        .negative(   NSLocalizedString("addObservationVC_useImageMetadata_negative", comment: ""), { [weak self] in
                                                            self?._observationLocation.set(.items(item: (location, false)))
                                                            self?.findLocality(location: location)
                                                        })])))
                    
                } else {
                    self?._observationLocation.set(.items(item: (location, false)))
                    self?.findLocality(location: location)
                }
            default: return
            }
        })
        return manager
    }()
    
    
    func start(action: AddObservationVC.Action) {
        switch action {
        case .new, .newNote:
            userObservation = UserObservation()
            setupState.set(.items(item: ()))
            if (userObservation.observationLocation?.item == nil) {
                locationManager.start()
            } else if let location = observationLocation.value?.item, userObservation.locality?.locality == nil {
                findLocality(location: location.item)
            }
        case .editNote(node: let note):
            userObservation = UserObservation(note)
        case .edit(observationID: let id):
            setupState.set(.loading)
            DataService.instance.getObservation(withID: id) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    self?.setupState.set(.error(error: error, handler: nil))
                case .success(let observation):
                    self?.userObservation = UserObservation(observation: observation, session: self?.session)
                    self?.setupState.set(.items(item: ()))
                }
                }
            }
        }

func reset() {
    userObservation = UserObservation()
    _predictionResults.set(.empty)
    uploadState.set(.empty)
    start(action: .new)
}

    func addImage(newObservationImage: UserObservation.Image) {
    if _images.value.count == 0 && mushroom == nil {
        getPredictions(imageURL: newObservationImage.url)
    }
    
    func reset() {
        userObservation = UserObservation()
        _predictionResults.set(.empty)
        uploadState.set(.empty)
        start(action: .new)
    }
    
    func addImage(newObservationImage: UserObservation.Image) {
        if _images.value.count == 0 && mushroom == nil {
            getPredictions(imageURL: newObservationImage.url)
        }
        
        _images.value.append(newObservationImage)
        addedImage.post(value: newObservationImage)
        if let imageLocation = newObservationImage.url.getExifLocation(), let currentObservationLocation = _observationLocation.value?.item, currentObservationLocation.item.distance(from: imageLocation) > imageLocation.horizontalAccuracy {
            showNotification.post(value: (Notification.useImageMetadata(precision: imageLocation.horizontalAccuracy),
                                          .action(backgroundColor: UIColor.appSecondaryColour(), actions: [
                                            .positive(NSLocalizedString("addObservationVC_useImageMetadata_positive", comment: ""), { [weak self] in
                                                self?._observationLocation.set(.items(item: (imageLocation, false)))
                                                self?.observationDate = imageLocation.timestamp
                                                self?.setupState.set(.items(item: ()))
                                                self?.findLocality(location: imageLocation)
                                            }),
                                            .negative(NSLocalizedString("addObservationVC_useImageMetadata_negative", comment: ""), {})])))
        }
    }
}

    func removeImage(newObservationImage: UserObservation.Image) {
        guard let index = _images.value.firstIndex(where: {$0.url == newObservationImage.url}) else {return}
    switch newObservationImage.type {
    case .new:
        ELFileManager.deleteImage(imageURL: newObservationImage.url)
        _images.value.remove(at: index)
        removedImage.post(value: index)
    case .uploaded(id: let id, _, _):
        session.deleteImage(id: id) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?._images.set(self?._images.value ?? [])
                self?.showNotification.post(value: (Notification.error(error: error), .error(actions: nil)))
            case .success:
                self?._images.value.remove(at: index)
                self?.removedImage.post(value: index)
            }
        }
    case .locallyStored:
        ELFileManager.deleteImage(imageURL: newObservationImage.url)
        _images.value.remove(at: index)
        removedImage.post(value: index)
        
    }
    
    if _images.value.isEmpty {
        _predictionResults.set(.empty)
    }
}
    
    func setLocality(locality: Locality?) {
        if let locality = locality {
            _locality.set((locality, false))
        } else {
            _locality.set(nil)
        }
    }
    
    func setLocalityLockedState(locked: Bool) {
        if let locality = _locality.value {
            _locality.set((locality.locality, locked))
        }
    }

    func setObservationLocation(_ location: CLLocation?) {
        if let location = location {
            _observationLocation.set(.items(item: (location, false)))
        } else {
            _observationLocation.set(.empty)
        }
    }
    
    func setLocationLockedState(locked: Bool) {
        if let location = observationLocation.value?.item {
            _observationLocation.set(.items(item: (location.item, locked)))
        }
    }
    
    func setPredictionResults(_ pr: Section<PredictionResult>.State) {
        _predictionResults.set(pr)
    }
    
    private func findLocality(location: CLLocation) {
        _localities.set(.loading)
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { [weak self] result in
            switch result {
            case .success(let localities):
                self?._localities.set(.items(item: localities))
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if let closest = closest {
                    self?._locality.set((closest, false))
                    self?.showNotification.post(value: (Notification.foundLocationAndLocality(observationLocation: location, locality: closest),
                                                        .success))
                } else {
                    self?.showNotification.post(value: (.localityError(error: nil), .error(actions: nil)))
                }
            case .failure(let error):
                self?._localities.set(.error(error: error, handler: nil))
                self?.showNotification.post(value: (.localityError(error: error), .error(actions: nil)))
            }
        }
    }

private func getPredictions(imageURL: URL) {
    guard let image = UIImage(url: imageURL) else {return}
    _predictionResults.set(.loading)
    DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
        switch result {
        case .failure(let error):
            self?._predictionResults.set(.error(error: error, handler: nil))
        case .success(let predictionResults):
            self?._predictionResults.set(.items(items: predictionResults))
        }
    }
}

    func performAction() {
    switch action {
    case .new:
            uploadNew()
    case .edit(observationID: let id):
            edit(id: id)
    case .newNote:
        saveNew()
    case .editNote(node: let note):
        editNote(note)
    }
}
    
    private func isValid() -> Bool {
        if let validationError = userObservation.validate(overrideAccuracy: false) {
            switch validationError {
            case .lowAccuracy:
                showNotification.post(value: (Notification.userObservationValidationError(error: validationError), ELNotificationView.Style.action(backgroundColor: .appSecondaryColour(), actions: [
                                                                                                                                .positive(NSLocalizedString("Yes, find my location", comment: ""), { [weak self] in
                                                                                                                                    self?.locationManager.start()
                                                                                                                                }),
                                                                                                                                .negative(NSLocalizedString("No, I'll adjust it myself", comment: ""), {})])))
            default: showNotification.post(value: (Notification.userObservationValidationError(error: validationError), ELNotificationView.Style.error(actions: nil)))
            }
            return false
        } else {
            return true
        }
    }
    
 func uploadNew() {
    guard isValid() else {return}
        uploadState.set(.loading)
        session.uploadObservation(userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let data):
                if data.uploadedImagesCount == self?._images.value.count {
                    self?.showNotification.post(value: (Notification.successfullUpload(id: data.observationID), ELNotificationView.Style.success))
                } else {
                    self?.showNotification.post(value: (Notification.uploadWithError(message: String(format: NSLocalizedString("Although an error occured uploading the image/s. %d out of %d images has been successfully uploaded", comment: ""), data.uploadedImagesCount, self?._images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                }
            }
            
            self?.uploadState.set(.empty)
    }
}
    
     private func edit(id: Int) {
        guard isValid() else {return}
        uploadState.set(.loading)
        session.editObservation(id: id, userObservation: userObservation) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let data):
                if data.uploadedImagesCount == self?.userObservation.images.filter({$0.type == .new}).count {
                    self?.showNotification.post(value: (Notification.editCompleted(id: data.observationID), ELNotificationView.Style.success))
                } else {
                    self?.showNotification.post(value: (Notification.editWithError(message: String(format: NSLocalizedString("Although an error occured uploading the image/s. %d out of %d images has been successfully uploaded", comment: ""), data.uploadedImagesCount, self?._images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                }
            }
        }
    }
    
    
     func saveNew() {
        uploadState.set(.loading)
        Database.instance.notesRepository.save(userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let _):
                self?.showNotification.post(value: (Notification.noteSave, ELNotificationView.Style.success))
            }
            
            self?.uploadState.set(.empty)
        }
    }
    
     func editNote(_ note: CDNote) {
        uploadState.set(.loading)
        Database.instance.notesRepository.saveChanges(note: note, userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showNotification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let _):
                self?.showNotification.post(value: (Notification.noteSave, ELNotificationView.Style.success))
            }
            
            self?.uploadState.set(.empty)
        }
    }
    
    func deleteNote() {
        switch action {
        case .editNote(node: let cdNote):
            Database.instance.notesRepository.delete(note: cdNote) { [weak self] result in
                self?.showNotification.post(value: (Notification.noteSave, ELNotificationView.Style.success))
            }
        default: return
        }
    }
    
    func deleteObservation() {
        uploadState.set(.loading)
        switch action {
        case .edit(observationID: let id):
            session.deleteObservation(id: id) { [weak self] (result) in
                switch result {
                case .failure(let error): break
                case .success(_):
                    self?.showNotification.post(value: (Notification.deleteSuccesful, ELNotificationView.Style.success))
                }
              
            }
        default: return
        }
        
    }
    
    func setCustomLocation(location: CLLocation) {
        _observationLocation.set(.items(item: (location, false)))
        findLocality(location: location)
    }
    
    func refindLocation() {
        locationManager.start()
    }
}
