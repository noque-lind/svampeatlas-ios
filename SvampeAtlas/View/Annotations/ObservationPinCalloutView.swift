//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationPinCalloutView: UIView {

    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var button: UIButton = {
       let button = UIButton(type: UIButtonType.custom)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "agaricus-arvensis1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var observationView: ObservationView = {
       let view = ObservationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private var observation: Observation!
    weak var delegate: MapViewDelegate? = nil
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let button = button.hitTest(convert(point, to: button), with: event) {
            return button
        } else {
            return nil
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.alpha = 0
        
        self.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        addSubview(button)
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: self.topAnchor)
    }
    
    func show(imageView: UIImageView) {
        imageViewWidthConstraint.isActive = false
        imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 100)
        imageViewWidthConstraint.isActive = true
        
        imageViewHeightConstraint.isActive = false
        imageViewTopConstraint.isActive = true
    
        self.alpha = 1
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.superview!.layoutIfNeeded()
            
        }) { (_) in
            self.setupContent()
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = UIColor.appSecondaryColour().withAlphaComponent(1.0)
                self.observationView.alpha = 1
            }, completion: nil)
        }
    }
    
    func hide(animated: Bool) {
        imageViewWidthConstraint.isActive = false
        
        imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 120)
        
        imageViewWidthConstraint.isActive = true
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.superview!.layoutIfNeeded()
                self.alpha = 0
            }) { (_) in
                self.reset()
            }
        } else {
            alpha = 0
            reset()
        }
    }
    
    func configure(imageView: UIImageView, observation: Observation) {
        observationView.configure(observation: observation)
        self.observation = observation
        
        self.imageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        self.imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalTo: imageView.widthAnchor)
        self.imageViewWidthConstraint.isActive = true
        self.imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalTo: imageView.heightAnchor)
        self.imageViewHeightConstraint.isActive = true
        self.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        self.imageView.layer.cornerRadius = imageView.frame.width / 2
        self.layer.cornerRadius = imageView.frame.width / 2
        self.superview!.layoutIfNeeded()
    }
    
    
    private func reset() {
        DispatchQueue.main.async {
            self.observationView.removeFromSuperview()
            self.imageViewTopConstraint.isActive = false
            self.imageViewWidthConstraint.isActive = false
            self.backgroundColor = UIColor.appSecondaryColour().withAlphaComponent(0.0)
            self.observationView.alpha = 0
            
            if let superView = self.superview {
                superView.layoutIfNeeded()
            }
            self.removeFromSuperview()
        }
    }
    
    private func setupContent() {
        addSubview(observationView)
        observationView.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 8).isActive = true
        observationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        observationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        observationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
    }
    
    

}

extension ObservationPinCalloutView {
    @objc func buttonPressed() {
        delegate?.shouldShowObservationDetails(observation: observation)
    }
}
