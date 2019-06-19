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
    
    private lazy var redlistStackViewViewAndToxicityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var observationsTableView: ObservationsTableView = {
        let tableView = ObservationsTableView(automaticallyAdjustHeight: true)
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
    
    func configure(_ mushroom: Mushroom) {
        self.mushroom = mushroom
        configureHeader(title: mushroom.danishName != nil ? NSAttributedString(string: mushroom.danishName!, attributes: [NSAttributedString.Key.font: UIFont.appTitle()]): mushroom.fullName.italized(font: UIFont.appTitle()), subtitle: mushroom.danishName != nil ? mushroom.fullName.italized(font: UIFont.appPrimary()): nil, user: nil)
        configureText(title: "Beskrivelse", text: mushroom.attributes?.diagnosis)
        configureText(title: "Forvekslingsmuligheder", text: mushroom.attributes?.similarities)
        
        var informationArray = [(String, String)]()
        if let totalObservations = mushroom.totalObservations {
            informationArray.append(("Antal danske fund", "\(totalObservations)"))
        }
        
        if let latestAcceptedRecord = mushroom.lastAcceptedObservation {
            informationArray.append(("Seneste danske fund", Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
        if let updatedAt = mushroom.updatedAt {
            informationArray.append(("Sidst opdateret d.:", Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        configureInformation(information: informationArray)
        
        configureRedlistInformation(redlistStatus: mushroom.redlistData?.status)
//        configureToxicityInformation(toxicityLevel: mushroom.attributes?.toxicityLevel)
        configureHeatMap(taxonID: mushroom.id)
        configureLatestObservationsView(taxonID: mushroom.id)
    }
    
    private func configureRedlistInformation(redlistStatus: String?) {
        guard let status = redlistStatus else {return}
        
        let redlistView = RedlistView(detailed: true)
        redlistStackViewViewAndToxicityStackView.addArrangedSubview(redlistView)
        redlistView.configure(status)
        contentStackView.addArrangedSubview(redlistStackViewViewAndToxicityStackView)
    }
    
    private func configureToxicityInformation(toxicityLevel: ToxicityLevel?) {
        guard let toxicityLevel = toxicityLevel else {return}
        
        let toxicityView = ToxicityView()
        redlistStackViewViewAndToxicityStackView.addArrangedSubview(toxicityView)
        toxicityView.configure(toxicityLevel)
        
        if redlistStackViewViewAndToxicityStackView.superview == nil {
            contentStackView.addArrangedSubview(redlistStackViewViewAndToxicityStackView)
        }
    }
    
    private func configureHeatMap(taxonID: Int) {
        _ = addContent(title: "Fund i nærheden", content: heatMap)
        heatMap.shouldLoad = true
        
        if locationManager.permissionsNotDetermined {
            heatMap.showError(error: LocationManagerError.permissionDenied) { [unowned locationManager] in
                locationManager.start()
            }
        } else {
            locationManager.start()
        }
    }
    
    private func configureLatestObservationsView(taxonID: Int) {
        _ = addContent(title: "Seneste observationer", content: observationsTableView)
        
        observationsTableView.tableViewState = .Loading
        
        DataService.instance.getObservationsForMushroom(withID: taxonID, limit: 15, offset: 0) { [weak observationsTableView] (result) in
            switch result {
            case .Error(let error):
                observationsTableView?.tableViewState = .Error(error, nil)
            case .Success(let observations):
                observationsTableView?.tableViewState = .Paging(items: observations, max: nil)
            }
        }
        
        observationsTableView.didRequestAdditionalDataAtOffset = {tableView, offset, _ in
            var allObservations = tableView.tableViewState.currentItems()
            tableView.tableViewState = .Loading
            
            DataService.instance.getObservationsForMushroom(withID: taxonID, limit: 15, offset: offset, completion: { [weak tableView] (result) in
                switch result {
                case .Error(let error):
                    tableView?.tableViewState = .Error(error, nil)
                case .Success(let observations):
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
    func locationRetrieved(location: CLLocation) {
        guard let taxonID = mushroom?.id else {return}
        let geometry = API.Geometry(coordinate: location.coordinate, radius: 80000.0, type: .rectangle)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: geometry.radius, longitudinalMeters: geometry.radius)
        
        heatMap.setRegion(region: region, selectAnnotationAtCenter: false, animated: false)
        
        DataService.instance.getObservationsWithin(geometry: geometry, taxonID: taxonID) { [weak heatMap] (result) in
            heatMap?.shouldLoad = false
            
            switch result {
            case .Success(let observations):
                DispatchQueue.main.async {
                heatMap?.addObservationAnnotations(observations: observations)
                }
               
            case .Error(let error):
                heatMap?.showError(error: error)
            }
    }
    }
    
    func locationInaccessible(error: LocationManagerError) {
        heatMap.showError(error: error)
    }
    
    func userDeniedPermissions() {
        heatMap.showError(error: LocationManagerError.permissionDenied) {
            DispatchQueue.main.async {
                if let bundleId = Bundle.main.bundleIdentifier,
                    let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
