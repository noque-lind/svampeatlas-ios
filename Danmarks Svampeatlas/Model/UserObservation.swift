//
//  UserObservation.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import CoreLocation.CLLocation
import ELKit
import Foundation

class UserObservation {
    
    struct Image: Equatable {
        
        enum `Type`: Equatable {
            case new
            case locallyStored
            case uploaded(id: Int, creationDate: Date?, userIsValidator: Bool)
        }
        
        public private(set) var type: Type
        public private (set) var url: URL
        public private(set) var filename: String
        
        var isDeletable: Bool {
            switch type {
            case .new, .locallyStored: return true
            case .uploaded(id: _, creationDate: let date, userIsValidator: let userIsValidator):
                guard userIsValidator == false else {return true}
                guard let date = date, let days = NSCalendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: date, to: Date()).day else {return false}
                return days > 7 ? false: true
            }
        }
    }
    
    enum ValidationError: AppError {
        
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
    var determinationNotes: String?
    var note: String?
    var images = [Image]()
    var observationLocation: (item: CLLocation, locked: Bool)?
    var locality: (locality: Locality, locked: Bool)?
    
    init() {
        if let substrateID = UserDefaultsHelper.defaultSubstrateID {
           substrate = CoreDataHelper.fetchSubstrateGroup(withID: substrateID)
            substrate?.isLocked = true
        }
        
        if let vegetationTypeID = UserDefaultsHelper.defaultVegetationTypeID {
            vegetationType = CoreDataHelper.fetchVegetationType(withID: vegetationTypeID)
            vegetationType?.isLocked = true
        }
        
        if let hostsIDS = UserDefaultsHelper.defaultHostsIDS {
            hosts = hostsIDS.compactMap({CoreDataHelper.fetchHost(withID: $0)})
            lockedHosts = true
        }
        
        if let locality = UserDefaultsHelper.lockedLocality {
            self.locality = (locality: locality, locked: true)
        }
        
        if let location = UserDefaultsHelper.lockedLocation {
            self.observationLocation = (item: location, locked: true)
        }
    }
    
    init(_ note: CDNote) {
        ecologyNote = note.ecologyNote
        self.note = note.note
        hosts = (note.hosts?.allObjects as? [CDHost])?.map({Host(from: $0)}) ?? []
        observationDate = note.observationDate ?? Date()
        
        if let specie = note.specie, let confidence = note.confidence, let dConfidence = DeterminationConfidence(rawValue: confidence) {
            mushroom = Mushroom(from: specie)
            determinationConfidence = dConfidence
        }
        
        if let substrate = note.substrate {
            self.substrate = Substrate(from: substrate)
        }
        
        if let vegetationType = note.vegetationType {
            self.vegetationType = VegetationType(from: vegetationType)
        }
        
        if let location = note.location {
            observationLocation = (CLLocation.init(coordinate: .init(latitude: location.latitude, longitude: location.longitude), altitude: 0, horizontalAccuracy: location.accuracy, verticalAccuracy: location.accuracy, timestamp: location.date ?? Date()), false)
        }
        
        if let cdLocality = note.locality, let locality = Locality(cdLocality) {
            self.locality = (locality, false)
        }
        
        if let images = note.images?.allObjects as? [CDNoteImage] {
            self.images = images.compactMap({
                guard let url = $0.url, let filename = $0.filename else {return nil}
                return .init(type: .locallyStored, url: url, filename: filename)
            })
        }
    }
    
    init(observation: Observation, session: Session?) {
        mushroom = Mushroom(id: observation.determination.id, fullName: observation.determination.fullName)
        substrate = observation.substrate
        vegetationType = observation.vegetationType
        ecologyNote = observation.ecologyNote
        note = observation.note
        hosts = observation.hosts
        
        if let dateString = observation.observationDate, let date = Date(ISO8601String: dateString) {
            observationDate = date
        } else {
            observationDate = Date()
        }
        
        observationLocation = (observation.location, false)
        locality =  (observation.locality != nil) ? (observation.locality!, false): nil
        images = observation.images?.compactMap({
                                                    guard let url = URL(string: $0.url), let createdDate = $0.createdDate else {return nil}
                                                    return Image(type: .uploaded(id: $0.id, creationDate: Date(ISO8601String: createdDate), userIsValidator: session?.user.isValidator ?? false), url: url, filename: "")}) ?? []
    }
    
    deinit {
        images.forEach({
            if $0.type == .new {
                ELFileManager.deleteImage(imageURL: $0.url)
            }
        })
    }
    
    func validate(overrideAccuracy: Bool) -> ValidationError? {
        guard mushroom != nil else {return .noMushroom}
        guard substrate != nil else {return .noSubstrateGroup}
        guard vegetationType != nil else {return .noVegetationType}
        guard locality != nil else {return .noLocality}
        guard let observationLocation = observationLocation?.item else {return .noCoordinates}
        if !overrideAccuracy {
            guard observationLocation.horizontalAccuracy <= 500 else {return .lowAccuracy(accurracy: observationLocation.horizontalAccuracy)}
        }
        return nil
    }
    
    func returnAsDictionary(session: Session, isEdit: Bool) -> [String: Any]? {
        guard let substrate = substrate else {return nil}
        guard let vegetationType = vegetationType else {return nil}
        guard let locality = locality else {return nil}
        guard let observationCoordinate = observationLocation else {return nil}

        var dict: [String: Any] = [:]
        dict["observationDate"] = observationDate.convert(into: "yyyy-MM-dd")
        dict["os"] = "iOS"
        dict["browser"] = "Native App"
        dict["substrate_id"] = substrate.id
        dict["vegetationtype_id"] = vegetationType.id
        dict["decimalLatitude"] = observationCoordinate.item.coordinate.latitude
        dict["decimalLongitude"] = observationCoordinate.item.coordinate.longitude
        dict["accuracy"] = observationCoordinate.item.horizontalAccuracy

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

        if let geoName = locality.locality.geoName {
            dict["geonameId"] = geoName.geonameId
            dict["geoname"] = ["geonameId": geoName.geonameId, "name": geoName.name, "adminName1": geoName.adminName1, "lat": geoName.lat, "lng": geoName.lng, "countryName": geoName.countryName, "countryCode": geoName.countryCode, "fcodeName": geoName.fcodeName, "fclName": geoName.fclName]
        } else {
            dict["locality_id"] = locality.locality.id
        }

        if !isEdit {
            guard let mushroom = mushroom  else {return nil}
            dict["determination"] = ["confidence": determinationConfidence.rawValue, "taxon_id": mushroom.id, "user_id": session.user.id, "notes": determinationNotes ?? ""]
        }

        return dict
    }
}
