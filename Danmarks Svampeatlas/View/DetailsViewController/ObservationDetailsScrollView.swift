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
        let alertVC = UIAlertController(title: "Rapporter stødende indhold", message: "Finder du en kommentar, eller brugergeneret indhold stødende? Giv en begrundelse her, så kikker vi på det.", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "Eg. stødende billeder"
        }
        
        alertVC.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak self, weak session] (action) in
            let comment = alertVC.textFields?.first?.text
            guard let observationID = self?.observation?.id else {return}
            session?.reportOffensiveContent(observationID: observationID, comment: comment, completion: {
                DispatchQueue.main.async {
                    let notification = ELNotificationView.appNotification(style: .success, primaryText: "Mange tak", secondaryText: "Din rapportering er med til at gøre Svampeatlas et sikkert sted", location: .bottom)
                    notification.show(animationType: .zoom)
                }
            })
        }))
        
        alertVC.addAction(UIAlertAction(title: "Afbryd", style: .cancel, handler: nil))
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
                button.setTitle("Rapporter stødende indhold", for: [])
                button.setTitleColor(UIColor.appRed(), for: [])
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
        configureText(title: "Kommentarer om voksested", text: observation.ecologyNote)
        configureText(title: "Andre noter", text: observation.note)
        
        var informationArray = [(String, String)]()
        
        if let validationStatus = observation.validationStatus {
            informationArray.append(("Valideringsstatus:", validationStatus))
        }
        
        if let observationDate = observation.date, observationDate != "" {
            informationArray.append(("Fundets dato:", Date(ISO8601String: observationDate)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
        
        if let substrate = observation.substrate {
            informationArray.append(("Substrat:", substrate.dkName))
        }
        
        if let vegetationType = observation.vegetationType {
            informationArray.append(("Vegetationstype:", vegetationType.dkName))
        }
        
        if let locality = observation.location, locality != "" {
            informationArray.append(("Lokalitet:", locality))
        }
        
        
        configureInformation(information: informationArray)
        configureMapView(observation: observation)
        
        if showSpeciesView {
            configureSpeciesView(taxonID: observation.speciesProperties.id)
        }
        
        configureComments(observationID: observation.id)
        
        if session != nil {
            contentStackView.addArrangedSubview(reportContentView)
        }
    }
    
    private func configureMapView(observation: Observation) {
        contentStackView.addArrangedSubview(mapView)
        mapView.addObservationAnnotations(observations: [observation])
        let coordinate = CLLocationCoordinate2D.init(latitude: observation.coordinates.last!, longitude: observation.coordinates.first!)
        mapView.setRegion(center: coordinate, zoomMetres: 50000)
        
        mapView.wasTapped = { [unowned self] in
            let mapVC = MapVC()
            mapVC.mapView.addObservationAnnotations(observations: [observation])
            mapVC.mapView.setRegion(center: coordinate, zoomMetres: 50000)
            self.customDelegate?.pushVC(mapVC)
        }
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
