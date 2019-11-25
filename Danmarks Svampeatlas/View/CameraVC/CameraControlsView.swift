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
    func usePhotoPressed()
    func noPhotoPressed()
    func presentVC(_ vc: UIViewController)
    func reset()
    func photoLibraryImagePicked(image: UIImage)
}

class CameraControlsView: UIView {
    
    enum TextLabelStates: String {
        case noPhoto = "Intet billede"
        case usePhoto = "Brug billede"
    }
    
    private lazy var captureButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Icons_Utils_CaptureButton"), for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoLibraryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5.0
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.layer.shadowOpacity = 0.5
        button.addTarget(self, action: #selector(leftImageViewPressed), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        return button
    }()
        

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = UIColor.appWhite()
        view.alpha = 0
        return view
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
        
        getPhotoLibraryThumbnail()
    
        addSubview(textButton)
        textButton.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        textButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        textButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        if hasNoPhotoButton {
            textButton.alpha = 1
            textButton.setTitle(TextLabelStates.noPhoto.rawValue, for: [])
        }
    }
    
    @objc private func captureButtonPressed() {
        delegate?.captureButtonPressed()
        setupSpinner()
    }

    
    @objc private func leftImageViewPressed() {
        if let state = TextLabelStates(rawValue: textButton.title(for: []) ?? "") {
            switch state {
            case .usePhoto:
                delegate?.reset()
            case .noPhoto:
                presentPhotoLibraryPicker()
            }
        } else {
            presentPhotoLibraryPicker()
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
    
    private func setupSpinner() {
    self.addSubview(activityIndicatorView)
    activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    activityIndicatorView.startAnimating()
    
    UIView.animate(withDuration: 0.2) {
    self.captureButton.alpha = 0
    self.activityIndicatorView.alpha = 1
        }
    }
    
    private func presentPhotoLibraryPicker() {
        PHPhotoLibrary.requestAuthorization { (authorization) in
            switch authorization {
            case .denied, .notDetermined, .restricted:
                return
//                DispatchQueue.main.async {
//                    ELNotificationView.appNotification(style: .error(actions: <#T##[ELNotificationView.Action]?#>), primaryText: <#T##String#>, secondaryText: <#T##String#>, location: <#T##ELNotificationView.Location#>)
//
//
//                    let notif = ELNotificationView(style: .error, attributes: .init(fillsScreen: true, cornerRadius: 0.0, borderWidth: 0.0, font: UIFont.appPrimaryHightlighed(), textColor: UIColor.appWhite()), primaryText: "Manglende tilladelser", secondaryText: "Du har ikke givet appen tilladelse til at se dit fotobibliotek. Du kan ændre det i indstillinger", location: .top)
//
//                    notif.onTap = {
//                        DispatchQueue.main.async {
//                            if let bundleId = Bundle.main.bundleIdentifier,
//                                let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
//                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                            }
//                        }
//                    }
//                    notif.show(animationType: .fromTop)
//                }
            case .authorized:
                DispatchQueue.main.async { [weak self] in
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.modalPresentationStyle = .fullScreen
//                    picker.delegate = self
                    self?.delegate?.presentVC(picker)
                }
            }
        }
        
    }
    
    func reset() {
        captureButton.alpha = 1
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.alpha = 0
        getPhotoLibraryThumbnail()
        
        if hasNoPhotoButton {
             textButton.setTitle(TextLabelStates.noPhoto.rawValue, for: [])
            textButton.alpha = 1
        } else {
            textButton.setTitle(nil, for: [])
            textButton.alpha = 0
        }
    }
    
    func askForConfirmation() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.alpha = 0
        
        photoLibraryButton.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_BackButton"), for: [])
        textButton.setTitle(TextLabelStates.usePhoto.rawValue, for: [])
        textButton.alpha = 1
    }
    
    private func getPhotoLibraryThumbnail() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            guard let phAsset = fetchResult.firstObject else {return}
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            
            
            PHImageManager.default().requestImage(for: phAsset, targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFit, options: requestOptions) { [weak photoLibraryButton] (image, _) in
                guard let image = image else {return}
                DispatchQueue.main.async {
                    photoLibraryButton?.setImage(image, for: [])
                }
            }
        case .denied, .restricted, .notDetermined:
            photoLibraryButton.setImage(#imageLiteral(resourceName: "Icons_Utils_PhotoLibrary"), for: [])
        }
    }
}
