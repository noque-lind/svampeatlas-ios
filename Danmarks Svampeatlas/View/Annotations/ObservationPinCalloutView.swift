//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationPinCalloutView: UIView {

    private lazy var button: UIButton = {
       let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CGFloat.cornerRadius()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var observationView: ObservationView = {
       let view = ObservationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private var observation: Observation?
    weak var delegate: MapViewDelegate?
    private var withImage: Bool
    
    private var imageViewWidthConstraint = NSLayoutConstraint()
    private var imageViewTopConstraint = NSLayoutConstraint()
    
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
    
    var wasPressed: ((_ observation: Observation) -> Void)?
    
    init(withImage: Bool) {
        self.withImage = withImage
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.cornerRadius = CGFloat.cornerRadius()
        alpha = 0
        
        addSubview(button)
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(observationView)
        observationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        observationView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        observationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
        
        if withImage {
            addSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: self.topAnchor)
            observationView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
            self.widthAnchor.constraint(equalToConstant: 310).isActive = true
        } else {
            observationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
            self.widthAnchor.constraint(equalToConstant: 250).isActive = true
        }
    }
    
    func configure(imageView: UIImageView?, observation: Observation) {
        self.observation = observation
        observationView.configure(observation: observation)
        
        if let imageURL = observation.images?.first?.url, withImage == true {
            DataService.instance.getImage(forUrl: imageURL, size: .mini) { (image, _) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        
        if let imageView = imageView {
            self.imageViewTopConstraint.isActive = false
            self.imageViewTopConstraint = self.imageView.topAnchor.constraint(equalTo: imageView.topAnchor)
            self.imageViewTopConstraint.isActive = true
            
            self.imageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
            
            self.imageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            
            self.imageViewWidthConstraint.isActive = false
            self.imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalTo: imageView.widthAnchor)
            self.imageViewWidthConstraint.isActive = true
        
            self.superview!.layoutIfNeeded()
        }
    }
    
    func show() {
        if withImage {
            imageViewWidthConstraint.isActive = false
            imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 100)
            imageViewWidthConstraint.isActive = true
            imageViewTopConstraint.isActive = false
            imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
            imageViewTopConstraint.isActive = true
        }
        self.alpha = 1
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.superview!.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(1.0)
                self.observationView.alpha = 1
            }, completion: nil)
        }
    }
    
    func hide(animated: Bool, completion: @escaping () -> Void) {
        if withImage {
            imageViewWidthConstraint.isActive = false
            imageViewWidthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: 120)
            imageViewWidthConstraint.isActive = true
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.superview!.layoutIfNeeded()
                self.alpha = 0
            }) { (_) in
                completion()
            }
        } else {
                completion()
        }
    }
}

extension ObservationPinCalloutView {
    @objc func buttonPressed() {
        guard let observation = observation else {return}
        wasPressed?(observation)
    }
}
