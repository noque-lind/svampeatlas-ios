//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {

    private var contentStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
   private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var secondaryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeaderDetails()
        label.textColor = UIColor.appWhite()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var mapView: UIView = {
        let mapView = MapView(mapViewConfiguration: MapViewConfiguration(regionRadius: 50000, mapViewCornerRadius: 10, descriptionViewContent: MapViewConfiguration.DescriptionViewContent(numberOfAnnotations: 10, withinRangeOf: "50km")))
        mapView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false
        //        mapView.centerOnUserLocation()
        return mapView
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
        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return stackView
    }()
    
    lazy var similarSpeciesView: SimilarSpeciesView = {
        let similarSpeciesView = SimilarSpeciesView()
        similarSpeciesView.translatesAutoresizingMaskIntoConstraints = false
        similarSpeciesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return similarSpeciesView
    }()
    
    
    
    
    init(topInset: CGFloat) {
        super.init(frame: CGRect.zero)
        contentInset = UIEdgeInsets.init(top: topInset, left: 0.0, bottom: 16.0, right: 0.0)
        scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 16, right: 0)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        contentStackView.spacing = 20
        contentInsetAdjustmentBehavior = .never
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentStackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
        contentStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        let upperStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 5

            if let title = mushroom.vernacularName_dk?.vernacularname_dk {
                titleLabel.text = title
                stackView.addArrangedSubview(titleLabel)
            }
            
            if let secondary = mushroom.vernacularName_dk?.appliedLatinName {
                secondaryTitleLabel.text = secondary
                stackView.addArrangedSubview(secondaryTitleLabel)
            }
            return stackView
        }()
       
        contentStackView.addArrangedSubview(upperStackView)
        
        if let økologi = mushroom.attributes?.oekologi {
                descriptionLabel.text = økologi
                contentStackView.addArrangedSubview(descriptionLabel)
        }
    
        
        
        contentStackView.addArrangedSubview(upperStackView)
        contentStackView.addArrangedSubview(descriptionLabel)
//            setupToxicityInformation(toxicityLevel: mushroom.toxicityLevel)
//            setupRedlistInformation(redlistData: mushroom.redlistData!)
            contentStackView.addArrangedSubview(similarSpeciesView)
            similarSpeciesView.mushrooms = [mushroom]
            contentStackView.addArrangedSubview(mapView)
        }
}
//
//private func setupToxicityInformation(toxicityLevel: ToxicityLevel?) {
//    guard let toxicityLevel = toxicityLevel else {return}
//
//    let stackView = UIStackView()
//    stackView.axis = .horizontal
//    stackView.spacing = 5
//
//    let toxicityIcon = UIImageView()
//    toxicityIcon.backgroundColor = UIColor.red
//    toxicityIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
//    toxicityIcon.translatesAutoresizingMaskIntoConstraints = false
//
//    let toxicityLabel = UILabel()
//    toxicityLabel.font = UIFont.appBold()
//    toxicityLabel.text = toxicityLevel.rawValue
//
//    switch toxicityLevel {
//    case .eatable:
//        toxicityLabel.textColor = UIColor.appGreen()
//    case .toxic:
//        toxicityLabel.textColor = UIColor.appRed()
//    case .cautious:
//        toxicityLabel.textColor = UIColor.appYellow()
//    }
//
//
//    stackView.addArrangedSubview(toxicityIcon)
//    stackView.addArrangedSubview(toxicityLabel)
//    toxicityStackView.addArrangedSubview(stackView)
//    contentStackView.addArrangedSubview(toxicityStackView)
//}
//
//private func setupRedlistInformation(redlistData: [Redlistdata?]) {
//    guard let redlistData = redlistData.first(where: {$0?.status != nil}) else {return}
//    guard let status = redlistData?.status else {return}
//
//    let redlistView = RedlistView(detailed: true)
//    redlistStackView.addArrangedSubview(redlistView)
//    redlistView.configure(status)
//    contentStackView.addArrangedSubview(redlistStackView)
//}
