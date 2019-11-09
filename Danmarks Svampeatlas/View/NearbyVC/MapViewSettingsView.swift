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

class MapViewSettingsView: UIView {
    
    private lazy var annotationButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_Location_Alternative"), for: UIControl.State.normal)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        return button
    }()
    
    private lazy var radiusLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.text = "1.2"
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.text = "1.2"
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Glyphs_Settings"), for: [])
        button.backgroundColor = UIColor.appPrimaryColour()
        button.layer.cornerRadius = 20
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
                button.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var toolBarContentView: UIView = {
        let view = UIView()
        view.addSubview(annotationButton)
        view.backgroundColor = UIColor.appSecondaryColour().withAlphaComponent(0.35)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        annotationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        annotationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let dividerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.appWhite()
            view.widthAnchor.constraint(equalToConstant: 1).isActive = true
            view.layer.cornerRadius = 0.5
            return view
        }()
        
        view.addSubview(dividerView)
        dividerView.leadingAnchor.constraint(equalTo: annotationButton.trailingAnchor, constant: 4).isActive = true
        dividerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        
        let radiusStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 3
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView: UIImageView = {
                let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalToConstant: 14).isActive = true
                view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                view.image =  #imageLiteral(resourceName: "Glyphs_Distance")
                return view
            }()
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(radiusLabel)
            return stackView
        }()
        
        view.addSubview(radiusStackView)
        radiusStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        radiusStackView.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 8).isActive = true
        
        
        let ageStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 3
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView: UIImageView = {
                let view = UIImageView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalToConstant: 14).isActive = true
                view.widthAnchor.constraint(equalToConstant: 14).isActive = true
                view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                view.image =  #imageLiteral(resourceName: "Glyphs_Age")
                return view
            }()
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(ageLabel)
            return stackView
        }()
        
        view.addSubview(ageStackView)
        ageStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        ageStackView.leadingAnchor.constraint(equalTo: radiusStackView.trailingAnchor, constant: 8).isActive = true
        
        view.addSubview(settingsButton)
        settingsButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        settingsButton.leadingAnchor.constraint(equalTo: ageStackView.trailingAnchor, constant: 8).isActive = true
        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        annotationButton.addGestureRecognizer(panGestureRecognizer)
        return view
    }()
    
    private var settingsView: ExpandedSettingsView?
    private var mapViewFilteringSettings: MapViewFilteringSettings
    private var isCollapsed = true
    var onSearchButtonPressed: (() -> ())?
    var onAnnotationRelease: ((UIButton) -> ())?
    
    
    init(mapViewFilteringSettings: MapViewFilteringSettings) {
        self.mapViewFilteringSettings = mapViewFilteringSettings
        super.init(frame: CGRect.zero)
        setupView()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
        super.layoutSubviews()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let settingsView = settingsView, settingsView.frame.contains(point) {
            return true
        } else {
            collapse()
            return super.point(inside: point, with: event)
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.35)
        addSubview(toolBarContentView)
        toolBarContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toolBarContentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        toolBarContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toolBarContentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    private func collapse() {
        guard !isCollapsed else {return}
        configure()
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.settingsView?.alpha = 0.0
            self.toolBarContentView.alpha = 1.0
        }) { (_) in
            self.settingsView?.removeFromSuperview()
            self.settingsView = nil
        }
    }
    
    @objc private func settingsButtonPressed() {
        isCollapsed = false
        
        let settingsView: ExpandedSettingsView = {
            let view = ExpandedSettingsView(mapViewfilteringSettings: mapViewFilteringSettings)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.appPrimaryColour()
            view.layer.cornerRadius = CGFloat.cornerRadius()
            view.onSearchButtonPressed = { [unowned self] in
                self.onSearchButtonPressed?()
                self.collapse()
            }
            return view
        }()
        
        self.settingsView = settingsView
        
        insertSubview(settingsView, at: 0)
        settingsView.leadingConstraint = settingsView.leadingAnchor.constraint(equalTo: settingsButton.leadingAnchor)
        settingsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        settingsView.topConstraint = settingsView.topAnchor.constraint(equalTo: topAnchor)
        settingsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        settingsView.topConstraint.isActive = true
        settingsView.leadingConstraint.isActive = true
        
        self.layoutIfNeeded()
        
        settingsView.topConstraint.isActive = false
        settingsView.leadingConstraint.isActive = false
        
        settingsView.topConstraint.constant = -150
        settingsView.topConstraint.isActive = true
        settingsView.leadingConstraint = settingsView.leadingAnchor.constraint(equalTo: leadingAnchor)
        settingsView.leadingConstraint.isActive = true
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.toolBarContentView.alpha = 0
            self.layoutIfNeeded()
        }) { (_) in
            self.settingsView?.setupView()
        }
    }
    
    

    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self)
            print(location.x)
            print(annotationButton.center.x)
            annotationButton.transform = annotationButton.transform.translatedBy(x: location.x - annotationButton.center.x, y: location.y - annotationButton.center.y)
            gesture.setTranslation(CGPoint(x: 0, y: -24), in: superview)
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
        case .changed:
            let translation = gesture.translation(in: superview)
            annotationButton.transform = annotationButton.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint.zero, in: superview)
        case .ended:
            onAnnotationRelease?(annotationButton)
            annotationButton.transform = CGAffineTransform.identity
        default:
            return
        }
    }
    
    private func configure() {
        ageLabel.text = "\(mapViewFilteringSettings.age) år."
        radiusLabel.text = "\((mapViewFilteringSettings.distance / 1000.0).rounded(toPlaces: 1)) km."
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

fileprivate class ExpandedSettingsView: UIView {
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        return label
    }()
    
    private lazy var distanceSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = Float(5000)
        slider.minimumValue = Float(1000)
        slider.tag = 40
        slider.tintColor = UIColor.appSecondaryColour()
        slider.value = Float(self.mapViewfilteringSettings.distance)
        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: UIControl.Event.valueChanged)
        return slider
    }()
    
    private var ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        return label
    } ()
    
    private lazy var ageSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = Float(8)
        slider.minimumValue = Float(1)
        slider.tag = 50
        slider.tintColor = UIColor.appSecondaryColour()
        slider.value = Float(self.mapViewfilteringSettings.age)
        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: UIControl.Event.valueChanged)
        return slider
    }()
    
    private var searchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.appGreen()
        button.setTitle("Ny søgning", for: [])
        button.titleLabel?.font = UIFont.appPrimaryHightlighed()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var onSearchButtonPressed: (() -> ())?
    var topConstraint = NSLayoutConstraint()
    var leadingConstraint = NSLayoutConstraint()
    var mapViewfilteringSettings: MapViewFilteringSettings
    
    init(mapViewfilteringSettings: MapViewFilteringSettings) {
        self.mapViewfilteringSettings = mapViewfilteringSettings
        super.init(frame: CGRect.zero)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        clipsToBounds = true
        
        let contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alpha = 0
            stackView.distribution = .fillEqually
            
            let distanceStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                stackView.addArrangedSubview(distanceLabel)
                stackView.addArrangedSubview(distanceSlider)
                return stackView
            }()
            
            let ageStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                stackView.addArrangedSubview(ageLabel)
                stackView.addArrangedSubview(ageSlider)
                return stackView
            }()
            
            stackView.addArrangedSubview(distanceStackView)
            stackView.addArrangedSubview(ageStackView)
            return stackView
        }()
        
        searchButton.alpha = 0
        addSubview(searchButton)
        searchButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: searchButton.topAnchor, constant: -8).isActive = true
        
        UIView.animate(withDuration: 0.1) {
            contentStackView.alpha = 1
            self.searchButton.alpha = 1
        }
    }
    
    @objc private func sliderChangedValue(sender: UISlider) {
        if sender.tag == 40 {
            mapViewfilteringSettings.distance = CGFloat(sender.value)
        } else if sender.tag == 50 {
            mapViewfilteringSettings.age = Int(sender.value)
        }
        configure()
    }
    
    @objc private func searchButtonPressed() {
        onSearchButtonPressed?()
    }
    
    private func configure() {
        distanceLabel.attributedText = mapViewfilteringSettings.distanceText
        ageLabel.attributedText = mapViewfilteringSettings.ageText
    }
}

