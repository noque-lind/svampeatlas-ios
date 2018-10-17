//
//  MapViewToolBarView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 16/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol MapViewToolBarViewDelegate: class {
    func handleAnnotationButtonGesture(gesture: UIPanGestureRecognizer)
}

class MapViewToolBarView: UIView {
    
    private var annotationButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "MKAnnotationPinSolid"), for: UIControl.State.normal)
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return button
    }()
    
    private var radiusLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.text = "1.2"
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.text = "1.2"
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }()
    
    weak var delegate: MapViewToolBarViewDelegate?

    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
        super.layoutSubviews()
    }
    
    private func setupView() {
        backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.35)
        
        addSubview(annotationButton)
        annotationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        annotationButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let dividerView: UIView = {
           let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.appWhite()
            view.widthAnchor.constraint(equalToConstant: 1).isActive = true
            view.layer.cornerRadius = 0.5
            return view
        }()
        
        addSubview(dividerView)
        dividerView.leadingAnchor.constraint(equalTo: annotationButton.trailingAnchor, constant: 4).isActive = true
        dividerView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        let radiusStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 2
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView: UIImageView = {
               let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalToConstant: 14).isActive = true
                view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                view.image =  #imageLiteral(resourceName: "Distance")
                return view
            }()
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(radiusLabel)
            return stackView
        }()
        
        addSubview(radiusStackView)
        radiusStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        radiusStackView.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 8).isActive = true
        
        
        let ageStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 2
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView: UIImageView = {
                let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalToConstant: 14).isActive = true
                view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                view.image =  #imageLiteral(resourceName: "Glyphs_age")
                return view
            }()
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(ageLabel)
            return stackView
        }()
        
        addSubview(ageStackView)
        ageStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ageStackView.leadingAnchor.constraint(equalTo: radiusStackView.trailingAnchor, constant: 8).isActive = true
        ageStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48).isActive = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        annotationButton.addGestureRecognizer(panGestureRecognizer)
        
    }
    

    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self)
            print(location.x)
            print(annotationButton.center.x)
            annotationButton.transform = annotationButton.transform.translatedBy(x: location.x - annotationButton.center.x, y: location.y - annotationButton.center.y)
            gesture.setTranslation(CGPoint(x: 0, y: -10), in: superview)
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
        case .changed:
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint.zero, in: superview)
        case .ended:
            delegate?.handleAnnotationButtonGesture(gesture: gesture)
            annotationButton.transform = CGAffineTransform.identity
        default:
            return
        }
        
        
        
    }
    
    func configure(filteringSettings: FilteringSettings) {
        ageLabel.text = "\(filteringSettings.age) år"
        radiusLabel.text = "\(Double(filteringSettings.regionRadius / 1000).rounded(toPlaces: 1))"
    }
    
//    @objc private func drag(control: UIControl, event: UIEvent) {
//        if let center = event.allTouches?.first?.location(in: superview) {
//            print(center)
//            annotationButton.center = center
//
//            if annotationButtonOriginCenter == nil {
//                annotationButtonOriginCenter = annotationButton.center
//            }
//            annotationButton.transform = CGAffineTransform.identity.translatedBy(x: -(annotationButtonOriginCenter!.x - center.x), y: -20)
//        }
//    }
    
}
