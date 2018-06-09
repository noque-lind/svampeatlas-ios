//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {

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
    
   private lazy var upperFirstLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var upperSecondLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeaderDetails()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var upperThirdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var informationStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
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
    

    private lazy var mapView: UIView = {
        let mapView = MapView(mapViewConfiguration: MapViewConfiguration(regionRadius: 50000, mapViewCornerRadius: 10, descriptionViewContent: MapViewConfiguration.DescriptionViewContent(numberOfAnnotations: 10, withinRangeOf: "50km")))
        mapView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false
        //        mapView.centerOnUserLocation()
        return mapView
    }()
    
lazy var similarSpeciesView: SimilarSpeciesView = {
        let similarSpeciesView = SimilarSpeciesView()
        similarSpeciesView.translatesAutoresizingMaskIntoConstraints = false
        similarSpeciesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return similarSpeciesView
    }()
    
    init(topInset: CGFloat) {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        contentInset = UIEdgeInsets.init(top: topInset, left: 0.0, bottom: 0, right: 0.0)
        scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
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
        configureUpperStackView(isObservation: false, first: mushroom.vernacularName_dk?.appliedLatinName, second: mushroom.vernacularName_dk?.vernacularname_dk, third: mushroom.attributes?.oekologi)
        
        let numberOfObservations = mushroom.statistics?.total_count ?? 0
        let latestObservation = mushroom.statistics?.last_accepted_record ?? "Aldrig"
        configureInformationStackView(informations: [("Antal danske fund:", "\(numberOfObservations)"), ("Seneste danske fund", latestObservation)])
        configureRedlistInformation(redlistStatus: mushroom.redlistData?.first?.status)
        configureToxicityInformation(toxicityLevel: mushroom.toxicityLevel)
        

            contentStackView.addArrangedSubview(similarSpeciesView)
            similarSpeciesView.mushrooms = [mushroom]
            contentStackView.addArrangedSubview(mapView)
        }
    
    public func configureScrollView(withObservation observation: Observation) {
        configureUpperStackView(isObservation: true, first: observation.determinationView?.taxon_danishName, second: observation.observedBy, third: observation.locality?.name)
    }
    
    
    private func configureUpperStackView(isObservation: Bool, first: String?, second: String?, third: String?) {
        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alignment = .center
            
            if let first = first {
                if isObservation {
                    upperFirstLabel.text = "Fund af: \(first)"
                } else {
                    upperFirstLabel.text = first
                }
                stackView.addArrangedSubview(upperFirstLabel)
            }
            
            if let second = second {
                if isObservation {
                    let userStackView = UIStackView()
                    userStackView.axis = .horizontal
                    userStackView.spacing = 5
                    
                    let iconView = UIImageView()
                    iconView.image = #imageLiteral(resourceName: "ListView")
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
                    
                    upperSecondLabel.text = second
                    userStackView.addArrangedSubview(iconView)
                    userStackView.addArrangedSubview(upperSecondLabel)
                    stackView.addArrangedSubview(userStackView)
                } else {
                    upperSecondLabel.text = second
                    stackView.addArrangedSubview(upperSecondLabel)
                }
                
            }
            
            if let third = third {
                if isObservation {
                    let locationStackView = UIStackView()
                    locationStackView.axis = .horizontal
                    locationStackView.spacing = 5
                    
                    let iconView = UIImageView()
                    iconView.image = #imageLiteral(resourceName: "ListView")
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
                    
                    upperThirdLabel.text = third
                    locationStackView.addArrangedSubview(iconView)
                    locationStackView.addArrangedSubview(upperThirdLabel)
                    stackView.addArrangedSubview(locationStackView)
                } else {
                    upperThirdLabel.textAlignment = NSTextAlignment.justified
                    upperThirdLabel.numberOfLines = 0
                    upperThirdLabel.text = third
                    stackView.addArrangedSubview(upperThirdLabel)
                }
            }
            return stackView
        }()
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
        contentStackView.addArrangedSubview(informationStackView)
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
}
