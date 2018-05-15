//
//  MushroomDetailsScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit

class MushroomDetailsScrollView: UIScrollView {
    
    @IBOutlet weak var contentStackView: UIStackView!
    
    
    
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var secondaryTitleLabel: UILabel = {
      let label = UILabel()
        label.font = UIFont.appHeaderDetails()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var mapView: UIView = {
        let mapView = MapView(mapViewConfiguration: MapViewConfiguration(regionRadius: 50000, mapViewCornerRadius: 10, descriptionViewContent: MapViewConfiguration.DescriptionViewContent(numberOfAnnotations: 10, withinRangeOf: "50km")))
        mapView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false
        mapView.centerOnUserLocation()
        return mapView
    }()
    
    lazy var primaryAndSecondaryTitleLabels: UIStackView = {
       let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryTitleLabel)
        return stackView
    }()
    
    lazy var toxicityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return stackView
    }()
    
    lazy var redlistStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return stackView
    }()
    
    lazy var similarSpeciesView: SimilarSpeciesView = {
        let similarSpeciesView = SimilarSpeciesView()
        similarSpeciesView.translatesAutoresizingMaskIntoConstraints = false
        similarSpeciesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return similarSpeciesView
    }()
    
    public func setupInsets(collectionViewHeight: CGFloat) {
        self.contentInset = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
        self.scrollIndicatorInsets = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    
    private func setupView() {
        contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        scrollIndicatorInsets = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        contentStackView.spacing = 20
        contentInsetAdjustmentBehavior = .never
    }
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        contentStackView.addArrangedSubview(primaryAndSecondaryTitleLabels)
        contentStackView.addArrangedSubview(descriptionLabel)
        setupToxicityInformation(toxicityLevel: mushroom.toxicityLevel)
        setupRedlistInformation(redlistData: mushroom.redlistData!)
        contentStackView.addArrangedSubview(similarSpeciesView)
        similarSpeciesView.mushrooms = [mushroom]
        contentStackView.addArrangedSubview(mapView)
        
        titleLabel.text = mushroom.vernacularName_dk?.vernacularname_dk
        secondaryTitleLabel.text = mushroom.vernacularName_dk?.appliedLatinName
        descriptionLabel.text = mushroom.attributes?.oekologi
    }
    
    private func setupToxicityInformation(toxicityLevel: ToxicityLevel?) {
        guard let toxicityLevel = toxicityLevel else {return}
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        let toxicityIcon = UIImageView()
        toxicityIcon.backgroundColor = UIColor.red
        toxicityIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        toxicityIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let toxicityLabel = UILabel()
        toxicityLabel.font = UIFont.appBold()
        toxicityLabel.text = toxicityLevel.rawValue
        
        switch toxicityLevel {
        case .eatable:
            toxicityLabel.textColor = UIColor.appGreen()
        case .toxic:
            toxicityLabel.textColor = UIColor.appRed()
        case .cautious:
            toxicityLabel.textColor = UIColor.appYellow()
        }
        
        
        stackView.addArrangedSubview(toxicityIcon)
        stackView.addArrangedSubview(toxicityLabel)
        toxicityStackView.addArrangedSubview(stackView)
        contentStackView.addArrangedSubview(toxicityStackView)
    }
    
    private func setupRedlistInformation(redlistData: [Redlistdata?]) {
        guard let redlistData = redlistData.first(where: {$0?.status != nil}) else {return}
        guard let status = redlistData?.status else {return}
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        let redlistContainerView = UIView()
        redlistContainerView.translatesAutoresizingMaskIntoConstraints = false
        redlistContainerView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        let redlistView = UIView()
        redlistContainerView.addSubview(redlistView)
        redlistView.translatesAutoresizingMaskIntoConstraints = false
        redlistView.layer.cornerRadius = (15 - 8) / 2
        redlistView.leadingAnchor.constraint(equalTo: redlistContainerView.leadingAnchor, constant: 4).isActive = true
        redlistView.trailingAnchor.constraint(equalTo: redlistContainerView.trailingAnchor, constant: -4).isActive = true
        redlistView.topAnchor.constraint(equalTo: redlistContainerView.topAnchor, constant: 4).isActive = true
        redlistView.bottomAnchor.constraint(equalTo: redlistContainerView.bottomAnchor, constant: -4).isActive = true
        
        
        let redlistLabel = UILabel()
        redlistLabel.font = UIFont.appBold()
        redlistLabel.text = status
        redlistView.backgroundColor = UIColor.appRed()
        
//        switch toxicityLevel {
//        case .eatable:
//            toxicityLabel.textColor = UIColor.appGreen()
//        case .toxic:
//            toxicityLabel.textColor = UIColor.appRed()
//        case .cautious:
//            toxicityLabel.textColor = UIColor.appYellow()
//        }
        
        
        stackView.addArrangedSubview(redlistContainerView)
        stackView.addArrangedSubview(redlistLabel)
        redlistStackView.addArrangedSubview(stackView)
        contentStackView.addArrangedSubview(redlistStackView)
    }
    

}
