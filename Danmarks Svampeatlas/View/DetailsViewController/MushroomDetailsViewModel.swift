//
//  MushroomDetailsViewModel.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 03/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import Foundation
import MapKit

class DetailsViewControllerViewModel: NSObject {
    
    enum `Type` {
        case mushroom(id: Int)
        case observation(id: Int)
    }
    
    let type: Type
    
    lazy var mushroom = ELListener<SimpleState<Mushroom>>.init(.empty)
    lazy var observation = ELListener<SimpleState<Observation>>(.empty)
    
    lazy var relatedObservations = ELListener<State<Observation>>.init(.empty)
    
    lazy var nearbyObservations = ELListener<SimpleState<[Observation]>>.init(.empty)
    lazy var userRegion = ELListener<SimpleState<MKCoordinateRegion>>.init(.empty)
    lazy var observationComments = ELListener<SimpleState<[Comment]>>.init(.empty)
    
    private lazy var locationManager: LocationManager = {
        let manager = LocationManager(accuracy: .low)
        manager.state.observe(listener: { [weak self] state in
            guard let type = self?.type else {return}
            switch type {
            case .mushroom(id: let id):
                switch state {
                case .locating:
                    self?.userRegion.set(.loading)
                    self?.nearbyObservations.set(.loading)
                case .foundLocation(location: let location):
                    let geometry = API.Geometry(coordinate: location.coordinate, radius: 80000.0, type: .rectangle)
                    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: geometry.radius, longitudinalMeters: geometry.radius)
                    self?.userRegion.set(.items(item: region))
                    self?.fetchNearbyObservations(id: id, geometry: geometry)
                case .error(error: let error):
                    self?.userRegion.set(.error(error: error, handler: { (_) in
                        self?.locationManager.start()
                    }))
                case .stopped: return
                }
                
            case .observation(id: let id):
                return
            }
        })
        return manager
    }()
    
    private init(type: Type) {
        self.type = type
        super.init()
        switch type {
        case .observation:
        return
        case .mushroom:
            if locationManager.permissionsNotDetermined {
                userRegion.set(.error(error: LocationManager.LocationManagerError.permissionsUndetermined, handler: { (_) in
                    self.locationManager.start()
                }))
            } else {
                locationManager.start()
            }
        }
    }
    
    convenience init(observationID: Int, showSpecies: Bool) {
        self.init(type: .observation(id: observationID))
        fetchObservation(id: observationID, onlyComments: false, fetchMushroomToo: showSpecies)
    }
    
    convenience init(observation: Observation, showSpecies: Bool) {
        self.init(type: .observation(id: observation.id))
        self.observation.set(.items(item: observation))
        fetchObservation(id: observation.id, onlyComments: true)
        if showSpecies {
            fetchMushroom(id: observation.determination.id)
        }
    }
    
    convenience init(mushroomID: Int) {
        self.init(type: .mushroom(id: mushroomID))
        fetchMushroom(id: mushroomID)
    }
    
    convenience init(mushroom: Mushroom) {
        self.init(type: .mushroom(id: mushroom.id))
        self.mushroom.set(.items(item: mushroom))
        fetchRelatedObservations(id: mushroom.id)
    }
    
    private func fetchRelatedObservations(id: Int) {
        relatedObservations.set(.loading)
        DataService.instance.getObservationsForMushroom(withID: id, limit: 20, offset: 0) { [weak relatedObservations] (result) in
            switch result {
            case .failure(let error):
                relatedObservations?.set(.error(error: error, handler: nil))
            case .success(let observations):
                relatedObservations?.set(.items(items: observations))
            }
        }
    }
    
    private func fetchNearbyObservations(id: Int, geometry: API.Geometry) {
        nearbyObservations.set(.loading)
        DataService.instance.getObservationsWithin(geometry: geometry, taxonID: id) { (result) in
            switch result {
            case .success(let observations):
                self.nearbyObservations.set(.items(item: observations))
            case .failure(let error):
                self.nearbyObservations.set(.error(error: error, handler: nil))
            }
    }
    }
    
    private func fetchObservation(id: Int, onlyComments: Bool, fetchMushroomToo: Bool = false) {
        if onlyComments {
            observationComments.set(.loading)
        } else {
            observationComments.set(.loading)
            observation.set(.loading)
        }
        DataService.instance.getObservation(withID: id) { [weak self] (result) in
            switch result {
            case .failure(let error):
                if onlyComments {
                    self?.observationComments.set(.error(error: error, handler: nil))
                } else {
                    self?.observationComments.set(.error(error: error, handler: nil))
                    self?.observation.set(.error(error: error, handler: nil))
                }
            case .success(let observation):
                if onlyComments {
                    self?.observationComments.set(.items(item: observation.comments))
                } else {
                    self?.observationComments.set(.items(item: observation.comments))
                    self?.observation.set(.items(item: observation))
                }
                if fetchMushroomToo {
                    self?.fetchMushroom(id: observation.determination.id)
                }
            }
        }
    }
    
    private func fetchMushroom(id: Int) {
        mushroom.set(.loading)
        DataService.instance.getMushroom(withID: id) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.mushroom.set(.error(error: error, handler: nil))
            case .success(let mushroom):
                self?.mushroom.set(.items(item: mushroom))
            }
        }
    }
}
