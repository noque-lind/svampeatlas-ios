//
//  CameraControlsVieew.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import Photos
import ELKit


protocol CameraControlsViewDelegate: class {
    func captureButtonPressed()
    func photoLibraryButtonPressed()
    func usePhotoPressed()
    func noPhotoPressed()
    func reset()
}

class CameraControlsView: UIView {
    
    enum TextLabelStates: String {
        case noPhoto = "Intet billede"
        case usePhoto = "Brug billede"
    }
    
    private lazy var captureButton: CaptureButton = {
        let button = CaptureButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.pressed = { [weak self] in
            self?.delegate?.captureButtonPressed()
            button.showSpinner(true)
        }
        
        return button
    }()
    
    private lazy var photoLibraryButton: PhotoLibraryButton = {
        let button = PhotoLibraryButton()
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.pressed = { [unowned textButton, unowned self] in
            if let state = TextLabelStates(rawValue: textButton.title(for: []) ?? "") {
                switch state {
                case .usePhoto:
                    self.delegate?.reset()
                case .noPhoto:
                    self.delegate?.photoLibraryButtonPressed()
                }
            } else {
                self.delegate?.photoLibraryButtonPressed()
            }
        }
        
        return button
    }()
    
    private lazy var textButton: UIButton = {
        let button = UIButton()
        button.alpha = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.appWhite(), for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .highlighted)
        
        button.titleLabel?.font = UIFont.appPrimary()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.addTarget(self, action: #selector(textButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var orientation: CameraVC.CameraRotation = .portrait {
        didSet {
            
            let rotationAngle: CGFloat
            
            switch self.orientation {
            case .landscapeLeft:
                rotationAngle = .pi / 2
            case .landscapeRight:
                rotationAngle = .pi / -2
            case .portrait:
                rotationAngle = 0
            }
            
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.textButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                self.photoLibraryButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                
            }, completion: nil)
        }
    }
    
    weak var delegate: CameraControlsViewDelegate? = nil
    private let hasNoPhotoButton: Bool
    
    
    init(hasNoPhotoButton: Bool) {
        self.hasNoPhotoButton = hasNoPhotoButton
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        captureButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(photoLibraryButton)
        photoLibraryButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        photoLibraryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        
        photoLibraryButton.setPhotosLibraryThumbnail()
    
        addSubview(textButton)
        textButton.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        textButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        textButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        if hasNoPhotoButton {
            textButton.alpha = 1
            textButton.setTitle(TextLabelStates.noPhoto.rawValue, for: [])
        }
    }
    
    @objc private func textButtonPressed() {
        guard let state = TextLabelStates(rawValue: textButton.title(for: []) ?? "") else {return}
        switch state {
        case .noPhoto:
            delegate?.noPhotoPressed()
        case .usePhoto:
            delegate?.usePhotoPressed()
        }
    }
        
    func reset() {
        captureButton.alpha = 1
        captureButton.showSpinner(false)
        photoLibraryButton.setPhotosLibraryThumbnail()
        
        if hasNoPhotoButton {
            textButton.setTitle(TextLabelStates.noPhoto.rawValue, for: [])
            textButton.alpha = 1
        } else {
            textButton.setTitle(nil, for: [])
            textButton.alpha = 0
        }
    }
    
    func askForConfirmation() {
        captureButton.showSpinner(false)
        photoLibraryButton.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_BackButton"), for: [])
        textButton.setTitle(TextLabelStates.usePhoto.rawValue, for: [])
        textButton.alpha = 1
    }
}
