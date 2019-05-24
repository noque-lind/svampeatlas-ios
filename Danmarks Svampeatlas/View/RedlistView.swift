//
//  RedlistView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class RedlistView: UIView {

    private var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appWhite()
        label.font = UIFont.appPrimaryHightlighed()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backgroundView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.addSubview(label)
        
        view.clipsToBounds = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        return view
    }()
    
    private lazy var detailsLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    private var detailed: Bool
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 2
    }
    
    init(detailed: Bool = false) {
        self.detailed = detailed
        super.init(frame: CGRect.zero)
        setupView(detailed: detailed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView(detailed: Bool) {
        backgroundColor = UIColor.clear
        addSubview(backgroundView)
        if detailed {
            backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            
            
            addSubview(detailsLabel)
            detailsLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            detailsLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            detailsLabel.leadingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 4).isActive = true
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        } else {
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    func configure(_ redlistStatus: String?, black: Bool = false) {
        label.text = redlistStatus
        if let redlistStatus = redlistStatus {
        switch redlistStatus {
        case "LC", "NT":
            backgroundView.backgroundColor = UIColor.appGreen()
            if detailed {
                detailsLabel.text = "Ikke en truet art"
            }
        case "CR", "EN":
            backgroundView.backgroundColor = UIColor.appRed()
            if detailed {
                detailsLabel.text = "Truet art"
            }
        case "VU":
            backgroundView.backgroundColor = UIColor.appYellow()
            if detailed {
                detailsLabel.text = "Sårbar art"
            }
        
        case "DD":
            backgroundView.backgroundColor = UIColor.gray
            if detailed {
                detailsLabel.text = "Vides ikke"
            }
        default:
            backgroundView.backgroundColor = UIColor.clear
        }
        } else {
            backgroundView.backgroundColor = UIColor.clear
            label.text = ""
        }
        
        if detailed && black {
            detailsLabel.textColor = UIColor.appPrimaryColour()
        } else {
            if detailed {
                detailsLabel.textColor = UIColor.white
            }
        }
    }
}
