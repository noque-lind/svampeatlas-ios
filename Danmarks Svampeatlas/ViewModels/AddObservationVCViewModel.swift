//
//  NewObservation.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 09/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import ImageIO
import MapKit
import Then
import UIKit

class AddObservationViewModel: NSObject {
    
    enum Notification {
        case validationError(error: UserObservation.ValidationError)
        case error(error: AppError)
        case useImageMetadata(precision: Double)
        case uploaded(id: Int)
        case uploadedWithError(message: String)
        case editCompleted(id: Int)
        case deleted
        case noteSave
        case editWithError(message: String)
        
        var title: String {
            switch self {
            case .deleted:
                return ""
            case .editWithError, .editCompleted:
                return NSLocalizedString("message_observationUpdated", comment: "")
            case .noteSave:
                return NSLocalizedString("message_noteSaved", comment: "")
            case .uploadedWithError:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .uploaded:
                return NSLocalizedString("addObservationVC_successfullUpload_title", comment: "")
            case .validationError(error: let error):
                return error.title
            case .error(error: let error): return error.title
            case .useImageMetadata: return NSLocalizedString("addObservationVC_useImageMetadata_title", comment: "")
            }
        }
        
        var message: String {
            switch self {
            case .deleted: return ""
            case .noteSave:
                return NSLocalizedString("message_noteSaved_message", comment: "")
            case .editWithError(message: let message):
                return message
            case .editCompleted(id: let id):
                return "DMS: \(id)"
            case .uploadedWithError(message: let message):
                return message
            case .uploaded(id: let id):
                return "DMS: \(id)"
            case .validationError(error: let error):
                return error.message
            case .error(error: let error): return error.message
            case .useImageMetadata(precision: let precision):
                return String(format: NSLocalizedString("addObservationVC_useImageMetadata_message", comment: ""), "\(precision.rounded(toPlaces: 2))")
            }
        }
    }
    
    let session: Session
    let context: AddObservationVC.Action
    
    // We initialize with a new UserObservation just to make sure, when we actually init viewModel, we get the didSet callback
    private var userObservation: UserObservation = UserObservation() {
        didSet {
            // When a new userObservation is assigned, we always want to make sure the location listener contains the newest value
            if let observationLocation = userObservation.observationLocation {
                _observationLocation.set(.items(item: observationLocation))
            } else {
                _observationLocation.set(.empty)
            }
            
            // When a new userObservation is assigned, we always want to make sure the locality listener contains the newest value
            if let locality = userObservation.locality {
                _locality.set(locality)
                _localities.set(.items(item: [locality.locality]))
            } else {
                _locality.set(nil)
                _localities.set(.empty)
            }

            // When a new userObservation is assigned, we always want to make sure the images listener contains the newest value
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
            
            // If the selected mushroom is one of the predictionresults, we add it to the determination notes.
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
    
    var hosts: (items: [Host], locked: Bool) {
        get {
            return userObservation.hosts
        }
        set {
            userObservation.hosts = newValue
        }
    }
        
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
        if value.count >= 1 && self?.mushroom == nil {
            switch self?.context {
            case .new, .uploadNote: self?.getPredictions(imageURL: value[0].url)
            default: break
            }
        }
    }
    
    lazy var images = ELListenerImmutable(_images)
    
    private lazy var _locality = ELListener<(locality: Locality, locked: Bool)?>.init(nil) { [weak self] value in
        self?.userObservation.locality = value
        UserDefaultsHelper.lockedLocality = (value?.locked ?? false) ? value?.locality: nil
        
        // If locality is set to nil & location has been found, we want to start finding locality
        guard value == nil, let location = self?.observationLocation.value?.item else {return }
        self?.findLocality(location: location.item)
    }

    lazy var locality = ELListenerImmutable(_locality)
    
    private  lazy var _observationLocation = ELListener<SimpleState<(item: CLLocation, locked: Bool)>?>.init(nil) { [weak self] value in
        self?.userObservation.observationLocation = value?.item
        UserDefaultsHelper.lockedLocation = (value?.item?.locked ?? false) ? value?.item?.item: nil
        
        // If Observation location state is set to .empty, then we want to start location manager
        guard case .empty = value else {return}
        self?.locationManager.start()
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
    
    let notification = ELEvent<(Notification, ELNotificationView.Style)>.init()
    let presentVC = ELEvent<UIViewController>.init()
    
    init(action: AddObservationVC.Action, session: Session, predictionResults: [PredictionResult]? = nil) {
        self.context = action
        self.session = session
        super.init()
        self.start(action: action)
        if let predictionResults = predictionResults {
            _predictionResults.set(.items(items: predictionResults))
        }
    }
    
    // This object handles location fetching
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
                    self?.notification.post(value:
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
                    // When a location has been found, we want to fetch locality normally.
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
        case .editNote(node: let note):
            userObservation = UserObservation(note)
            setupState.set(.items(item: ()))
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
        case .uploadNote(note: let note):
            userObservation = UserObservation(note)
            setupState.set(.items(item: ()))
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
            switch context {
            case .new, .uploadNote: getPredictions(imageURL: newObservationImage.url)
            default: break
            }
        }
        
        _images.value.append(newObservationImage)
        addedImage.post(value: newObservationImage)
        if let imageLocation = newObservationImage.url.getExifLocation(), let currentObservationLocation = _observationLocation.value?.item, currentObservationLocation.item.distance(from: imageLocation) > imageLocation.horizontalAccuracy {
            notification.post(value: (Notification.useImageMetadata(precision: imageLocation.horizontalAccuracy),
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
                    self?.notification.post(value: (Notification.error(error: error), .error(actions: nil)))
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

    private func findLocality(location: CLLocation) {
        // If context is a new note, or an edit of a note, we do not find localities at all
        switch context {
        case .newNote, .editNote:
            if locality.value != nil {
                _locality.set(nil)
                _localities.set(.empty)
            }
            return
        default: break
        }
        _localities.set(.loading)
        DataService.instance.getLocalitiesNearby(coordinates: location.coordinate) { [weak self] result in
            switch result {
            case .success(let localities):
                self?._localities.set(.items(item: localities))
                let closest = localities.min(by: {$0.location.distance(from: location) < $1.location.distance(from: location)})
                
                if let closest = closest {
                    self?._locality.set((closest, false))
                }
            case .failure(let error):
                self?._localities.set(.error(error: error, handler: nil))
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
        switch context {
        case .new, .uploadNote:
            upload()
        case .edit(observationID: let id):
            edit(id: id)
        case .newNote:
            saveNew()
        case .editNote(node: let note):
            editNote(note)
        }
    }
    
    ///Check if current object is valid, and post error to user if not.
    private func isValid() -> Bool {
        if let validationError = userObservation.validate(overrideAccuracy: false) {
            switch validationError {
            case .lowAccuracy:
                notification.post(value: (Notification.validationError(error: validationError), ELNotificationView.Style.action(backgroundColor: .appSecondaryColour(), actions: [
                    .positive(NSLocalizedString("action_findLocation", comment: ""), { [weak self] in
                        self?.locationManager.start()
                    }),
                    .negative(NSLocalizedString("action_adjustSelf", comment: ""), {})])))
            default: notification.post(value: (Notification.validationError(error: validationError), ELNotificationView.Style.error(actions: nil)))
            }
            return false
        } else {
            return true
        }
    }
    
    
    /// Upload current object and post result to user
    func upload() {
        guard isValid() else {return}
        uploadState.set(.loading)
        session.uploadObservation(userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.notification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let data):
                if data.uploadedImagesCount == self?._images.value.count {
                    self?.notification.post(value: (Notification.uploaded(id: data.observationID), ELNotificationView.Style.success))
                } else {
                    self?.notification.post(value: (Notification.uploadedWithError(message: String(format: NSLocalizedString("addObservationError_imageUploadError", comment: ""), data.uploadedImagesCount, self?._images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                }
            }
            
            // If context is a note that is saved to storage, we need to delete it.
            switch self?.context {
            case .uploadNote(note: let note):
                Database.instance.notesRepository.delete(note: note) { _ in }
            case .editNote(node: let note):
                Database.instance.notesRepository.delete(note: note) { _ in }
            default: self?.uploadState.set(.empty)
            }
        }
    }
    
    private func edit(id: Int) {
        guard isValid() else {return}
        uploadState.set(.loading)
        session.editObservation(id: id, userObservation: userObservation) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.notification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success(let data):
                if data.uploadedImagesCount == self?.userObservation.images.filter({$0.type == .new}).count {
                    self?.notification.post(value: (Notification.editCompleted(id: data.observationID), ELNotificationView.Style.success))
                } else {
                    self?.notification.post(value: (Notification.editWithError(message: String(format: NSLocalizedString("addObservationError_imageUploadError", comment: ""), data.uploadedImagesCount, self?._images.value.count ?? 0)), ELNotificationView.Style.warning(actions: nil)))
                }
            }
        }
    }
    
    func saveNew() {
        uploadState.set(.loading)
        Database.instance.notesRepository.save(userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.notification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success:
                self?.notification.post(value: (Notification.noteSave, ELNotificationView.Style.success))
            }
            
            self?.uploadState.set(.empty)
        }
    }
    
    func editNote(_ note: CDNote) {
        uploadState.set(.loading)
        Database.instance.notesRepository.saveChanges(note: note, userObservation: userObservation) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.notification.post(value: (Notification.error(error: error), ELNotificationView.Style.error(actions: nil)))
            case .success:
                self?.notification.post(value: (Notification.noteSave, ELNotificationView.Style.success))
            }
            
            self?.uploadState.set(.empty)
        }
    }
    
    func deleteNote() {
        switch context {
        case .uploadNote(note: let cdNote):
            Database.instance.notesRepository.delete(note: cdNote) { [weak self] _ in
                self?.notification.post(value: (Notification.deleted, .success))
            }
        case .editNote(node: let cdNote):
            Database.instance.notesRepository.delete(note: cdNote) { [weak self] _ in
                self?.notification.post(value: (Notification.deleted, .success))
            }
        default: return
        }
    }
    
    func deleteObservation() {
        uploadState.set(.loading)
        switch context {
        case .edit(observationID: let id):
            session.deleteObservation(id: id) { [weak self] (result) in
                switch result {
                case .failure(let error): break
                case .success:
                    self?.notification.post(value: (Notification.deleted, ELNotificationView.Style.success))
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
