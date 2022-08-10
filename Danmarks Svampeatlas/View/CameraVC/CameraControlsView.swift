//
//  CameraControlsVieew.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import Photos
import UIKit

protocol CameraControlsViewDelegate: class {
    func photoLibraryButtonPressed(state: CameraControlsView.State)
    func captureButtonPressed()
    func textButtonPressed(state: CameraControlsView.State)
}

class CameraControlsView: UIView {
    
    enum State {
        case confirmation
        case regular
        case loading
    }
    
    private lazy var captureButton: CaptureButton = {
        let button = CaptureButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.pressed = { [unowned self] in
            self.delegate?.captureButtonPressed()
        }
        
        return button
    }()
    
    private lazy var photoLibraryButton: PhotoLibraryButton = {
        let button = PhotoLibraryButton()
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.pressed = { [unowned self] in
            self.delegate?.photoLibraryButtonPressed(state: self.state)
        }
        
        return button
    }()
    
    private lazy var textButton: CameraControlsTextButton = {
        let button = CameraControlsTextButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.pressed = { [unowned self] in
            self.delegate?.textButtonPressed(state: self.state)
        }
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
    
    weak var delegate: CameraControlsViewDelegate?
    private let hasNoPhotoButton: Bool
    private var state: State = .regular
    
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
    
        addSubview(textButton)
        textButton.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        textButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        textButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        setState(state: .regular)
    }
    
    func setState(state: State) {
        self.state = state
        
        switch state {
        case .regular:
            captureButton.isHidden = false
            captureButton.showSpinner(false)
            photoLibraryButton.isHidden = false
            photoLibraryButton.setPhotosLibraryThumbnail()
            
            if hasNoPhotoButton {
                textButton.setState(state: .noPhoto)
                textButton.isHidden = false
            } else {
                textButton.isHidden = true
            }
            
        case .confirmation:
            captureButton.isHidden = true
            photoLibraryButton.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_BackButton"), for: [])
            textButton.setState(state: .usePhoto)
            textButton.isHidden = false
            photoLibraryButton.isHidden = false
        case .loading:
            captureButton.isHidden = false
            captureButton.showSpinner(true)
            photoLibraryButton.isHidden = true
            textButton.isHidden = true
        }
    }
}
