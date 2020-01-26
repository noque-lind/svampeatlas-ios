//
//  ObservationDetailsScrollView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 30/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import MapKit
import ELKit

class ObservationDetailsScrollView: AppScrollView {
    
    private lazy var mapView: NewMapView = {
        let view = NewMapView(type: .observations(detailed: false))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var mushroomView: MushroomView = {
        let view = MushroomView(fullyRounded: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap = { [weak self] mushroom in
            self?.customDelegate?.pushVC(DetailsViewController(detailsContent: .mushroom(mushroom: mushroom, session: self?.session, takesSelection: nil)))
        }
        return view
    }()
    
    private lazy var commentsTableView: CommentsTableView = {
        
        let view = CommentsTableView(allowComments: (session != nil ? true: false), automaticallyAdjustHeight: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc private func reportContentButtonPressed() {
        let alertVC = UIAlertController(title: NSLocalizedString("observationDetailsScrollView_rapportContent_title", comment: ""), message: NSLocalizedString("observationDetailsScrollView_rapportContent_message", comment: ""), preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("observationDetailsScrollView_rapportContent_placeholder", comment: "")
        }
        
        alertVC.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak self, weak session] (action) in
            let comment = alertVC.textFields?.first?.text
            guard let observationID = self?.observation?.id else {return}
            session?.reportOffensiveContent(observationID: observationID, comment: comment, completion: {
                DispatchQueue.main.async {
                    let notification = ELNotificationView.appNotification(style: .success, primaryText: NSLocalizedString("observationDetailsScrollView_rapportContent_thankYou_title", comment: ""), secondaryText: NSLocalizedString("observationDetailsScrollView_rapportContent_thankYou_message", comment: ""), location: .bottom)
                    notification.show(animationType: .zoom)
                }
            })
        }))
        
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("observationDetailsScrollView_rapportContent_abort", comment: ""), style: .cancel, handler: nil))
        customDelegate?.presentVC(alertVC)
    }
    
    private lazy var reportContentView: UIView = {
        let view: UIView = {
           let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.clear
            view.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            let button: UIButton = {
                let button = UIButton()
                button.backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.4)
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                button.layer.cornerRadius = 5
                button.setTitle(NSLocalizedString("observationDetailsScrollView_rapportContent_title", comment: ""), for: [])
                button.setTitleColor(UIColor.red, for: [])
                button.titleLabel?.font = UIFont.appPrimaryHightlighed(customSize: 12)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(reportContentButtonPressed), for: .touchUpInside)
            return button
            }()
            
            
            view.addSubview(button)
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return view
        }()
        
        return view
    }()
    
    var session: Session?
    private var observation: Observation?
    
    
    init(session: Session?) {
        self.session = session
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(withObservation observation: Observation, showSpeciesView: Bool) {
        self.observation = observation
        
        
        configureHeader(title: observation.speciesProperties.name, subtitle: nil, user: observation.observedBy)
        addText(title: NSLocalizedString("observationDetailsScrollView_ecologyNotes", comment: ""), text: observation.ecologyNote)
        addText(title: NSLocalizedString("observationDetailsScrollView_notes", comment: ""), text: observation.note)
        
        var informationArray = [(String, String)]()
        
        switch observation.validationStatus {
        case .approved:
            informationArray.append((NSLocalizedString("observationDetailsScrollView_validationStatus", comment: ""), NSLocalizedString("observationDetailsScrollView_validationStatus_approved", comment: "")))
        case .rejected:
        informationArray.append((NSLocalizedString("observationDetailsScrollView_validationStatus", comment: ""), NSLocalizedString("observationDetailsScrollView_validationStatus_declined", comment: "")))
        case .verifying:
            informationArray.append((NSLocalizedString("observationDetailsScrollView_validationStatus", comment: ""), NSLocalizedString("observationDetailsScrollView_validationStatus_verifying", comment: "")))
        case .unknown:
            informationArray.append((NSLocalizedString("observationDetailsScrollView_validationStatus", comment: ""), NSLocalizedString("observationDetailsScrollView_validationStatus_unknown", comment: "")))
        }
        
        if let observationDate = observation.date, observationDate != "" {
            informationArray.append((NSLocalizedString("observationDetailsScrollView_observationDate", comment: ""), Date(ISO8601String: observationDate)?.convert(into: .medium, ignoreRecentFormatting: false, ignoreTime: true) ?? ""))
        }
        
        if let substrate = observation.substrate {
            informationArray.append((NSLocalizedString("observationDetailsScrollView_substrate", comment: ""), substrate.name))
        }
        
        if let vegetationType = observation.vegetationType {
            informationArray.append((NSLocalizedString("observationDetailsScrollView_vegetationType", comment: ""), vegetationType.name))
        }
        
        if let locality = observation.location, locality != "" {
            informationArray.append((NSLocalizedString("observationDetailsScrollView_location", comment: ""), locality))
        }
        
        
        addInformation(information: informationArray)
        configureMapView(observation: observation)
        
        if showSpeciesView {
            configureSpeciesView(taxonID: observation.speciesProperties.id)
        }
        
        configureComments(observationID: observation.id)
        
        if session != nil {
            addContent(title: nil, content: reportContentView)
        }
    }
    
    private func configureMapView(observation: Observation) {
        addContent(title: nil, content: mapView)
         let coordinate = CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!)
        
        mapView.addLocationAnnotation(location: coordinate)
        mapView.setRegion(center: coordinate, zoomMetres: 50000)
        mapView.wasTapped = { [unowned self] in
            let mapVC = MapVC()
            mapVC.mapView.addLocationAnnotation(location: coordinate)
            mapVC.mapView.setRegion(center: coordinate, zoomMetres: 50000)
            self.customDelegate?.pushVC(mapVC)
        }
    }
    
    private func configureSpeciesView(taxonID: Int?) {
        guard let taxonID = taxonID else {return}
        addContent(title: NSLocalizedString("observationDetailsScrollView_species", comment: ""), content: mushroomView)
        Spinner.start(onView: mushroomView)
        
        DataService.instance.getMushroom(withID: taxonID) { [weak mushroomView] (result) in
            switch result {
            case .failure(_):
                return
            case .success(let mushroom):
                DispatchQueue.main.sync { [weak mushroomView] in
                    Spinner.stop()
                    mushroomView?.configure(mushroom: mushroom)
                    mushroomView?.invalidateIntrinsicContentSize()
                }
            }
        }
    }
    
    private func configureComments(observationID: Int) {
        addContent(title: NSLocalizedString("observationDetailsScrollView_comments", comment: ""), content: commentsTableView)
        
        commentsTableView.tableViewState = .Loading
        ELKeyboardHelper.instance.registerObject(view: commentsTableView)
        
        DataService.instance.getObservation(withID: observationID) { [weak commentsTableView] (result) in
            DispatchQueue.main.async { [weak commentsTableView] in
                switch result {
                case .success(let observation):
                    if (observation.comments.count > 0) || (commentsTableView?.allowComments ?? false) {
                        commentsTableView?.tableViewState = TableViewState.Items(observation.comments)
                    } else {
//                     content?.removeFromSuperview()
                    }
                    
                case .failure(let error):
                    commentsTableView?.tableViewState = .Error(error, nil)
                }
            }
        }
        
        commentsTableView.sendCommentHandler = { [weak session, unowned commentsTableView] (text) in
            var currentComments = commentsTableView.tableViewState.currentItems()
            commentsTableView.tableViewState = .Loading
            
            session?.uploadComment(observationID: observationID, comment: text, completion: { [weak commentsTableView] (result) in
                switch result {
                case .failure(let error):
                    ELNotificationView.appNotification(style: .error(actions: nil), primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .bottom)
                        .show(animationType: .fromBottom)
                case .success(let comment):
                    currentComments.append(comment)
                    commentsTableView?.tableViewState = .Items(currentComments)
                }
            })
        }
    }
}
