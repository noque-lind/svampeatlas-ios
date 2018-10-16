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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 115).isActive = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appHeaderDetails()
        label.textColor = UIColor.appPrimaryColour()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appPrimaryColour()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(secondaryLabel)
        return stackView
    }()
    
    private lazy var lowerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var toxicityView: ToxicityView = {
        let toxicityView = ToxicityView()
        toxicityView.translatesAutoresizingMaskIntoConstraints = false
        toxicityView.isHidden = true
        return toxicityView
    }()
    
    private lazy var redlistView: RedlistView = {
        let redlistView = RedlistView(detailed: true)
        toxicityView.isHidden = true
        redlistView.translatesAutoresizingMaskIntoConstraints = false
        redlistView.heightAnchor.constraint(equalToConstant: 25).isActive = true
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
            stackView.spacing = 5
            stackView.addArrangedSubview(upperStackView)
            stackView.addArrangedSubview(lowerStackView)
            
            let toxicityStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .center
                stackView.addArrangedSubview(toxicityView)
                return stackView
            }()
            
            let redlistStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.addArrangedSubview(redlistView)
                return stackView
            }()
            
            stackView.addArrangedSubview(toxicityStackView)
            stackView.addArrangedSubview(redlistStackView)
            return stackView
        }()
        
        
        let contentContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.clear
            view.addSubview(informationStackView)
            informationStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
            informationStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
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
    private var mushroom: Mushroom?
    weak var delegate: NavigationDelegate? = nil {
        didSet {
            if delegate != nil {
                tapGestureRecognizer.isEnabled = true
            } else {
                tapGestureRecognizer.isEnabled = false
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        round()
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
        backgroundColor = UIColor.white
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func round() {
        let radius: CGFloat = 5.0
        if fullyRounded {
            layer.cornerRadius = radius
        } else {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
            layer.mask = shapeLayer
        }
    }
    
    private func configureLowerStackView(informations: [(String, String)]) {
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appPrimaryColour()
                label.text = withInfo.0
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appPrimaryColour()
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
        
        lowerStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        for information in informations {
            lowerStackView.addArrangedSubview(createStackView(information))
        }
    }
    
    @objc private func mushroomViewWasTapped() {
        guard let mushroom = mushroom else {return}
        delegate?.pushVC(DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom)))
    }
    
    func configure(mushroom: Mushroom) {
        self.mushroom = mushroom
        
        thumbImage.configureImage(url: mushroom.images?.first?.url)
        mainLabel.text = mushroom.danishName ?? mushroom.fullName
        secondaryLabel.text = mushroom.danishName != nil ? mushroom.fullName: nil
        
        var informationArray = [(String, String)]()
        if let totalObservations = mushroom.totalObservations {
            informationArray.append(("Antal danske fund:", "\(totalObservations)"))
        }
        
        if let latestAcceptedRecord = mushroom.lastAcceptedObservation {
            informationArray.append(("Seneste danske fund:", Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        
        if let updatedAt = mushroom.updatedAt, informationArray.count < 2 {
            informationArray.append(("Sidst opdateret d.:", Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        
        configureLowerStackView(informations: informationArray)
        redlistView.configure(mushroom.redlistData?.status, black: true)
        redlistView.isHidden = mushroom.redlistData != nil ? false: true
    }
}
