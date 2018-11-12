//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DetailsScrollView: UIScrollView {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var redlistStackViewViewAndToxicityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var mapView: MapView = {
        let mapView = MapView(mapViewConfiguration: MapViewConfiguration(filteringSettings: FilteringSettings(regionRadius: 50000, age: 1), mapViewCornerRadius: 10, shouldHaveDescriptionView: true))
        mapView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false
        //        mapView.centerOnUserLocation()
        return mapView
    }()
    
    private lazy var speciesViewStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var observationsTableViewStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.text = "SENESTE OBSERVATIONER"
            return label
        }()
        
        stackView.addArrangedSubview(label)
        return stackView
    }()
    
    lazy var similarSpeciesView: SimilarSpeciesView = {
        let similarSpeciesView = SimilarSpeciesView()
        similarSpeciesView.translatesAutoresizingMaskIntoConstraints = false
        similarSpeciesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return similarSpeciesView
    }()
    
    weak var customDelegate: NavigationDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        configureUpperStackView(isObservation: false, first: mushroom.danishName ?? mushroom.fullName, second: mushroom.danishName != nil ? mushroom.fullName: mushroom.danishName, third: mushroom.attributes?.ecology, fouth: mushroom.attributes?.diagnosis)
        
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
        configureInformationStackView(informations: informationArray)
        
        configureRedlistInformation(redlistStatus: mushroom.redlistData?.status)
        configureToxicityInformation(toxicityLevel: mushroom.attributes?.toxicityLevel)
        configureLatestObservationsView(taxonID: mushroom.id)
    }
    
    public func configureScrollView(withObservation observation: Observation, showSpeciesView: Bool) {
        configureUpperStackView(isObservation: true, first: observation.speciesProperties.name, second: observation.observedBy, third: observation.note, fouth: observation.ecologyNote)
        
        var informationArray = [(String, String)]()
        
        if let locality = observation.location, locality != "" {
            informationArray.append(("Lokalitet:", locality))
        }
        
        if let observationDate = observation.date, observationDate != "" {
            informationArray.append(("Fundets dato:", Date(ISO8601String: observationDate)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
        
        configureInformationStackView(informations: informationArray)
        
        contentStackView.addArrangedSubview(mapView)
        mapView.showObservationAt(coordinates: observation.coordinates)
        
        if showSpeciesView {
         configureSpeciesView(taxonID: observation.speciesProperties.id)
        }
        
        configureComments(comments: observation.comments)
    }
    
    private func configureComments(comments: [Comment]) {
        let commentsTableView: CommentsTableView = {
            let tableView = CommentsTableView()
            tableView.configure(comments: comments)
            return tableView
        }()
        
        contentStackView.addArrangedSubview(commentsTableView)
    }
    
    private func configureUpperStackView(isObservation: Bool, first: String?, second: String?, third: String?, fouth: String?) {
        if let first = first, first != "" {
            let label: UILabel = {
                let label = UILabel()
                label.font = UIFont.appHeader()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                return label
            }()
            
            if isObservation {
                label.text = "Fund af: \(first)"
            } else {
                label.text = first
            }
            upperStackView.addArrangedSubview(label)
        }
            
            if let second = second, second != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimary()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    return label
                }()
                
                if isObservation {
                    let userStackView = UIStackView()
                    userStackView.axis = .horizontal
                    userStackView.spacing = 5
                    
                    let iconView = UIImageView()
                    iconView.image = #imageLiteral(resourceName: "Profile")
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
                    
                    label.text = second
                    userStackView.addArrangedSubview(iconView)
                    userStackView.addArrangedSubview(label)
                    upperStackView.addArrangedSubview(userStackView)
                } else {
                    label.text = second
                    upperStackView.addArrangedSubview(label)
                }
            }
            
            if let third = third, third != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .justified
                    label.numberOfLines = 0
                    return label
                }()
                
                label.text = third
                upperStackView.addArrangedSubview(label)
            }
            
            if let fourth = fouth, fouth != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimary()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .justified
                    label.numberOfLines = 0
                    return label
                }()
                
                label.text = fourth
                upperStackView.addArrangedSubview(label)
            }
            contentStackView.addArrangedSubview(upperStackView)
    }
    
    private func configureInformationStackView(informations: [(String, String)]) {
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.0
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.1
                label.textAlignment = .right
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.addArrangedSubview(leftLabel)
                stackView.addArrangedSubview(rightLabel)
                return stackView
            }()
            return stackView
        }
        
        for information in informations {
            informationStackView.addArrangedSubview(createStackView(information))
        }
        if informationStackView.subviews.count > 0 {
            contentStackView.addArrangedSubview(informationStackView)
        }
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
    
    private func configureSpeciesView(taxonID: Int?) {
        guard let taxonID = taxonID else {return}
        
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.text = "ART"
        
        let mushroomView = MushroomView(fullyRounded: true)
        mushroomView.delegate = customDelegate
        mushroomView.translatesAutoresizingMaskIntoConstraints = false
        mushroomView.heightAnchor.constraint(equalToConstant: 134).isActive = true
        speciesViewStackView.addArrangedSubview(label)
        speciesViewStackView.addArrangedSubview(mushroomView)
        contentStackView.addArrangedSubview(speciesViewStackView)
        
        DataService.instance.getMushroom(withID: taxonID) { (appError, mushroom) in
            guard appError == nil, let mushroom = mushroom else {
                //                self.delegate?.presentViewController(vc: UIAlertController(title: appError!.title, message: appError!.message))
                return
            }
            
            DispatchQueue.main.async {
                mushroomView.configure(mushroom: mushroom)
            }
        }
    }
    
    private func configureLatestObservationsView(taxonID: Int?) {
        guard let taxonID = taxonID else {return}
        DataService.instance.getObservationsForMushroom(withID: taxonID) { (appError, observations) in
            guard appError == nil, let observations = observations, observations.count > 0 else {return}
            DispatchQueue.main.async {
                let observationsTableView = ObservationsTableView(automaticallyAdjustHeight: true)
                observationsTableView.translatesAutoresizingMaskIntoConstraints = false
                observationsTableView.delegate = self.customDelegate
                self.observationsTableViewStackView.addArrangedSubview(observationsTableView)
                self.contentStackView.addArrangedSubview(self.observationsTableViewStackView)
                observationsTableView.configure(observations: observations)
            }
        }
    }
}
