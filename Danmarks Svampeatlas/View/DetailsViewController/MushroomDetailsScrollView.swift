//
//  MushroomDetailsScrollView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 30/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class MushroomDetailsScrollView: AppScrollView {

    
    private lazy var observationsTableView: ObservationsTableView = {
        let tableView = ObservationsTableView(automaticallyAdjustHeight: true)
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.tableView.separatorColor = UIColor.appPrimaryColour()
        
        return tableView
    }()
    
    private lazy var heatMap: NewMapView = {
        let view = NewMapView(type: .observations(detailed: false))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return view
    }()
    
    private lazy var locationManager: LocationManager = {
        let manager = LocationManager()
        manager.delegate = self
        return manager
    }()
    
    private var mushroom: Mushroom?
    private var session: Session?
    
    
    override var customDelegate: NavigationDelegate? {
        didSet {
            //            self.observationsTableView.delegate = self.customDelegate
        }
    }
    
    init(session: Session?) {
        self.session = session
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(_ mushroom: Mushroom, takesSelection: Bool) {
        self.mushroom = mushroom
        if let localizedName = mushroom.localizedName {
            configureHeader(title: NSAttributedString(string: localizedName, attributes: [.font: UIFont.appTitle()]), subtitle: mushroom.fullName.italized(font: .appPrimary()), user: nil)
        } else {
            configureHeader(title: mushroom.fullName.italized(font: .appTitle()), subtitle: nil, user: nil)
        }
        
        
        if takesSelection {
            addText(title: NSLocalizedString("mushroomDetailsScrollView_validationTips", comment: ""), text: mushroom.attributes?.tipsForValidation)
        }
        
        addText(title: NSLocalizedString("mushroomDetailsScrollView_description", comment: ""), text: mushroom.attributes?.description)
        addText(title: NSLocalizedString("mushroomDetailsScrollView_eatability", comment: ""), text: mushroom.attributes?.eatability)
        addText(title: NSLocalizedString("mushroomDetailsScrollView_ecology", comment: ""), text: mushroom.attributes?.ecology)
        addText(title: NSLocalizedString("mushroomDetailsScrollView_similarities", comment: ""), text: mushroom.attributes?.similarities)
//
        var informationArray = [(String, String)]()
        if let totalObservations = mushroom.statistics?.acceptedCount {
            informationArray.append((NSLocalizedString("mushroomDetailsScrollView_acceptedRecords", comment: ""), "\(totalObservations)"))
        }

        if let latestAcceptedRecord = mushroom.statistics?.lastAcceptedRecord {
            informationArray.append((NSLocalizedString("mushroomDetailsScrollView_latestAcceptedRecord", comment: ""), Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
       
        if let updatedAt = mushroom.updatedAt {
            informationArray.append((NSLocalizedString("mushroomDetailsScrollView_latestUpdated", comment: ""), Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        addInformation(information: informationArray)
        configureRedlistAndToxicity(redlistStatus: mushroom.redlistStatus, isPoisonous: mushroom.attributes?.isPoisonous)
        configureHeatMap(taxonID: mushroom.id)
        configureLatestObservationsView(taxonID: mushroom.id)
    }
    
    private func configureRedlistAndToxicity(redlistStatus: String?, isPoisonous: Bool?) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.alignment = .center
            
            let toxicityView: ToxicityView = {
                let view = ToxicityView()
                view.configure(isPoisonous: isPoisonous ?? false)
                return view
            }()
            
            let redlistView: RedlistView = {
                let view = RedlistView(detailed: true)
                view.configure(redlistStatus)
                return view
            }()
            
            stackView.addArrangedSubview(toxicityView)
            stackView.addArrangedSubview(redlistView)
            return stackView
        }()
        
        addContent(title: nil, content: stackView)
    }
    
    private func configureHeatMap(taxonID: Int) {
        addContent(title: NSLocalizedString("mushroomDetailsScrollView_heatMap", comment: ""), content: heatMap)
        heatMap.shouldLoad = true
        
        if locationManager.permissionsNotDetermined {
            heatMap.showError(error: LocationManager.LocationManagerError.permissionsUndetermined) { [unowned locationManager] _ in
                locationManager.start()
            }
        } else {
            locationManager.start()
        }
    }
    
    private func configureLatestObservationsView(taxonID: Int) {
        addContent(title: NSLocalizedString("mushroomDetailsScrollView_latestObservations", comment: ""), content: observationsTableView)
        
        observationsTableView.tableViewState = .Loading
        
        DataService.instance.getObservationsForMushroom(withID: taxonID, limit: 15, offset: 0) { [weak observationsTableView] (result) in
            switch result {
            case .failure(let error):
                observationsTableView?.tableViewState = .Error(error, nil)
            case .success(let observations):
                observationsTableView?.tableViewState = .Paging(items: observations, max: nil)
            }
        }
        
        observationsTableView.didRequestAdditionalDataAtOffset = {tableView, offset, _ in
            var allObservations = tableView.tableViewState.currentItems()
            tableView.tableViewState = .Loading
            
            DataService.instance.getObservationsForMushroom(withID: taxonID, limit: 15, offset: offset, completion: { [weak tableView] (result) in
                switch result {
                case .failure(let error):
                    tableView?.tableViewState = .Error(error, nil)
                case .success(let observations):
                    allObservations.append(contentsOf: observations)
                    
                    if observations.count < 15 {
                         tableView?.tableViewState = .Items(allObservations)
                    } else {
                        tableView?.tableViewState = .Paging(items: allObservations, max: nil)
                    }
                }
            })
        }
        
        observationsTableView.didSelectItem = { [weak self] item in
            self?.customDelegate?.pushVC(DetailsViewController(detailsContent: .observation(observation: item, showSpeciesView: false, session: self?.session)))
        }
    }
}

extension MushroomDetailsScrollView: LocationManagerDelegate {
    func locationInaccessible(error: LocationManager.LocationManagerError) {
        heatMap.showError(error: error) { (recoveryAction) in
            guard let recoveryAction = recoveryAction else {return}
            switch recoveryAction {
            case .openSettings:
                if let bundleId = Bundle.main.bundleIdentifier,
                               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                               UIApplication.shared.open(url, options: [:], completionHandler: nil)
                           }
                
            default: return
            }
        }
    }
    
    func locationRetrieved(location: CLLocation) {
        guard let taxonID = mushroom?.id else {return}
        let geometry = API.Geometry(coordinate: location.coordinate, radius: 80000.0, type: .rectangle)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: geometry.radius, longitudinalMeters: geometry.radius)
        
        heatMap.setRegion(region: region, selectAnnotationAtCenter: false, animated: false)
        
        DataService.instance.getObservationsWithin(geometry: geometry, taxonID: taxonID) { [weak heatMap] (result) in
            heatMap?.shouldLoad = false
            
            switch result {
            case .success(let observations):
                DispatchQueue.main.async {
                heatMap?.addObservationAnnotations(observations: observations)
                }
               
            case .failure(let error):
                heatMap?.showError(error: error)
            }
    }
    }
}
