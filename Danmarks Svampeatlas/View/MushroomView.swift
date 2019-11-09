//
//  MushroomView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomView: UIView {
    
    private var thumbImage: RoundedImageView = {
        let view = RoundedImageView()
        view.configureRoundness(fullyRounded: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 115).isActive = true
        return view
    }()
     
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appPrimaryColour()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appPrimaryColour()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(secondaryLabel)
        return stackView
    }()
    
    private lazy var informationView: InformationView = {
        let view = InformationView(style: .dark)
        return view
    }()
//
//    private lazy var lowerStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 2
//        stackView.distribution = .fill
//        return stackView
//    }()
    
    private lazy var redlistStackView: UIStackView = {
       let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.alignment = .center
        stackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
            stackView.addArrangedSubview(redlistView)
            return stackView
    }()
    
    
    private lazy var redlistView: RedlistView = {
        let redlistView = RedlistView(detailed: true)
        redlistView.translatesAutoresizingMaskIntoConstraints = false
        return redlistView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        let informationStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = 20
            stackView.addArrangedSubview(upperStackView)
            stackView.addArrangedSubview(informationView)
//            stackView.addArrangedSubview(redlistStackView)
            return stackView
        }()
        
        
        let contentContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.clear
            view.addSubview(informationStackView)
            informationStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
            informationStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
            informationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
            informationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6).isActive = true
            return view
        }()
        
        stackView.addArrangedSubview(thumbImage)
        stackView.addArrangedSubview(contentContainerView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mushroomViewWasTapped))
        gestureRecognizer.isEnabled = false
        return gestureRecognizer
    }()
    
    private var fullyRounded: Bool
    public private(set) var mushroom: Mushroom?
    
    var onTap: ((_ mushroom: Mushroom) -> ())? {
        didSet {
            if onTap != nil {
                tapGestureRecognizer.isEnabled = true
            } else {
                tapGestureRecognizer.isEnabled = false
            }
        }
    }
    
    init(fullyRounded: Bool) {
        self.fullyRounded = fullyRounded
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor.white
        layer.cornerRadius = 5.0
        layer.maskedCorners = fullyRounded ? [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]: [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureLowerStackView(informations: [(String, String)]) {
        informationView.addInformation(information: informations)
        self.invalidateIntrinsicContentSize()
    }
    
    @objc private func mushroomViewWasTapped() {
        guard let mushroom = mushroom else {return}
        onTap?(mushroom)
    }
    
    func configure(mushroom: Mushroom) {
        informationView.reset()
        
        
        self.mushroom = mushroom

        if let image = mushroom.images?.first {
            thumbImage.isHidden = false
            thumbImage.configureImage(url: image.url)
        } else {
            thumbImage.isHidden = true
        }
       
        
        if let danishName =  mushroom.danishName {
            titleLabel.attributedText = nil
            titleLabel.font = UIFont.appPrimaryHightlighed()
            titleLabel.text = danishName
        } else {
            titleLabel.attributedText = mushroom.fullName.italized(font: UIFont.appPrimaryHightlighed())
        }
        
        secondaryLabel.attributedText = mushroom.danishName != nil ? mushroom.fullName.italized(font: UIFont.appPrimary()): nil
        secondaryLabel.isHidden = mushroom.danishName != nil ? false: true
        
        var informationArray = [(String, String)]()
        
        if let totalObservations = mushroom.statistics?.acceptedCount {
            informationArray.append(("Antal danske fund:", "\(totalObservations)"))
        }
        
        if let latestAcceptedRecord = mushroom.statistics?.lastAcceptedRecord {
            informationArray.append(("Seneste fund:", Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        
        if let updatedAt = mushroom.updatedAt, informationArray.count < 2 {
            informationArray.append(("Sidst opdateret d.:", Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        
        configureLowerStackView(informations: informationArray)
        
        if let redlistStatus = mushroom.redlistStatus {
            redlistView.configure(redlistStatus, black: true)
            redlistStackView.isHidden = false
        } else {
            redlistStackView.isHidden = true
            
        }
    
    }
}
