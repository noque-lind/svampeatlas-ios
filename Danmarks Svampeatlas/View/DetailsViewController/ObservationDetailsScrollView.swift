//
//  ObservationDetailsScrollView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 30/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import MapKit

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
            self?.customDelegate?.pushVC(DetailsViewController(detailsContent: .mushroom(mushroom: mushroom, takesSelection: nil)))
        }
        return view
    }()
    
    private lazy var commentsTableView: CommentsTableView = {
        
        let view = CommentsTableView(allowComments: (session != nil ? true: false), automaticallyAdjustHeight: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var session: Session?
    
    init(session: Session?) {
        self.session = session
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(withObservation observation: Observation, showSpeciesView: Bool) {
        configureHeader(title: observation.speciesProperties.name, subtitle: nil, user: observation.observedBy)
        configureText(title: "Noter", text: observation.note)
        configureText(title: "Økologi noter", text: observation.ecologyNote)
        
        var informationArray = [(String, String)]()
        
        if let locality = observation.location, locality != "" {
            informationArray.append(("Lokalitet:", locality))
        }
        
        if let observationDate = observation.date, observationDate != "" {
            informationArray.append(("Fundets dato:", Date(ISO8601String: observationDate)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
        
        configureInformation(information: informationArray)
        configureMapView(observation: observation)
        
        if showSpeciesView {
            configureSpeciesView(taxonID: observation.speciesProperties.id)
        }
        
        configureComments(observationID: observation.id)
    }
    
    
    
    private func configureMapView(observation: Observation) {
        contentStackView.addArrangedSubview(mapView)
        mapView.addObservationAnnotations(observations: [observation])
        let coordinate = CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!)
        mapView.setRegion(center: coordinate, zoomMetres: 50000)
    }
    
    private func configureSpeciesView(taxonID: Int?) {
        guard let taxonID = taxonID else {return}
        let content = addContent(title: "Art", content: mushroomView)
        Spinner.start(onView: mushroomView)
        
        DataService.instance.getMushroom(withID: taxonID) { [weak mushroomView, weak content] (result) in
            switch result {
            case .Error(_):
                DispatchQueue.main.async { [weak content] in
                    content?.removeFromSuperview()
                }
            case .Success(let mushroom):
                DispatchQueue.main.sync { [weak mushroomView] in
                    Spinner.stop()
                    mushroomView?.configure(mushroom: mushroom)
                    mushroomView?.invalidateIntrinsicContentSize()
                }
            }
        }
    }
    
    private func configureComments(observationID: Int) {
        let content = addContent(title: "Kommentarer", content: commentsTableView)
        
        commentsTableView.tableViewState = .Loading
        ELKeyboardHelper.instance.registerObject(view: commentsTableView)
        
        DataService.instance.getObservation(withID: observationID) { [weak commentsTableView, weak content] (result) in
            DispatchQueue.main.async { [weak commentsTableView, weak content] in
                switch result {
                case .Success(let observation):
                    if (observation.comments.count > 0) || (commentsTableView?.allowComments ?? false) {
                    
                        commentsTableView?.tableViewState = TableViewState.Items(observation.comments)
                    } else {
                     content?.removeFromSuperview()
                    }
                    
                case .Error(let error):
                    commentsTableView?.tableViewState = .Error(error, nil)
                }
            }
        }
        
        commentsTableView.sendCommentHandler = { [weak session, unowned commentsTableView] (text) in
            var currentComments = commentsTableView.tableViewState.currentItems()
            commentsTableView.tableViewState = .Loading
            
            session?.uploadComment(observationID: observationID, comment: text, completion: { [weak commentsTableView] (result) in
                switch result {
                case .Error(let error):
                    let notification = ELNotificationView.appNotification(style: .error, primaryText: "Din kommentar kunne ikke tilføjes", secondaryText: error.errorDescription, location: .bottom)
                    notification.show(animationType: .fromBottom)
                case .Success(let comment):
                    currentComments.append(comment)
                    commentsTableView?.tableViewState = .Items(currentComments)
                }
            })
        }
    }
}
