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
        label.text = "Champignon"
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Lorem Ipsum er ganske enkelt fyldtekst fra print- og typografiindustrien. Lorem Ipsum har været standard fyldtekst siden 1500-tallet, hvor en ukendt trykker sammensatte en tilfældig spalte for at trykke en bog til sammenligning af forskellige skrifttyper. Lorem Ipsum har ikke alene overlevet fem århundreder, men har også vundet indpas i elektronisk typografi uden væsentlige ændringer. Sætningen blev gjordt kendt i 1960'erne med lanceringen af Letraset-ark, som indeholdt afsnit med Lorem Ipsum, og senere med layoutprogrammer som Aldus PageMaker, som også indeholdt en udgave af Lorem Ipsum."
        return label
    }()
    
    lazy var map: MKMapView = {
       let map = MKMapView()
        map.heightAnchor.constraint(equalToConstant: 500).isActive = true
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 10
        map.isUserInteractionEnabled = false
        return map
    }()
    
    lazy var titleAndDescription: UIStackView = {
       let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        return stackView
    }()
    
    public func setupInsets(collectionViewHeight: CGFloat) {
        self.contentInset = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
        self.scrollIndicatorInsets = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    
    private func setupView() {
        contentStackView.spacing = 20
    }
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        contentStackView.addArrangedSubview(titleAndDescription)
        contentStackView.addArrangedSubview(map)
    }
}
