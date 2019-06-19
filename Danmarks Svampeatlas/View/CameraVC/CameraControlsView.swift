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
    func presentVC(_ vc: UIViewController)
    func photoFromPhotoLibraryWasChoosen(image: UIImage)
    func photoLibraryPickerCancelled()
    func noPhotoButtonPressed()
}

class CameraControlsView: UIView {
    
    private lazy var captureButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CaptureBtn"), for: [])
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
        button.addTarget(self, action: #selector(photoLibraryButtonPressed), for: .touchUpInside)
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
    
    private lazy var noPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Intet billede", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.appWhite(), for: [])
        button.titleLabel?.font = UIFont.appPrimaryHightlighed()
        button.addTarget(self, action: #selector(noPhotoButtonPressed), for: .touchUpInside)
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
                
                self.noPhotoButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                self.photoLibraryButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
                
                
            }, completion: nil)
        }
    }
    
    weak var delegate: CameraControlsViewDelegate? = nil
    
    init(hasNoPhotoButton: Bool) {
        super.init(frame: CGRect.zero)
        setupView(hasNoPhotoButton: hasNoPhotoButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView(hasNoPhotoButton: Bool) {
        backgroundColor = UIColor.clear
        
        addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        captureButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(photoLibraryButton)
        photoLibraryButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        photoLibraryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        
        getPhotoLibraryThumbnail()
        
        if hasNoPhotoButton {
            addSubview(noPhotoButton)
            noPhotoButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            noPhotoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        }
    }
    
    @objc private func captureButtonPressed() {
        delegate?.captureButtonPressed()
        
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicatorView.startAnimating()
        
        UIView.animate(withDuration: 0.2) {
            self.captureButton.alpha = 0
            self.activityIndicatorView.alpha = 1
        }
    }
    
    @objc private func photoLibraryButtonPressed() {
        PHPhotoLibrary.requestAuthorization { (authorization) in
            switch authorization {
            case .denied, .notDetermined, .restricted:
                DispatchQueue.main.async {
                    let notif = ELNotificationView.appNotification(style: .error, primaryText: "Manglende tilladelser", secondaryText: "Du har ikke givet appen tilladelse til at se dit photobibliotek. Du kan ændre det i indstillinger", location: .center)
                    notif.onTap = {
                        DispatchQueue.main.async {
                            if let bundleId = Bundle.main.bundleIdentifier,
                                let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
                    notif.show(animationType: .zoom)
                }
            case .authorized:
                DispatchQueue.main.async { [weak self] in
                     let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    self?.delegate?.presentVC(picker)
                }
            }
        }
    }
    
    @objc private func noPhotoButtonPressed() {
        delegate?.noPhotoButtonPressed()
    }
    
    func reset() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.alpha = 0
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
            
            
            PHImageManager.default().requestImage(for: phAsset, targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFill, options: requestOptions) { [weak photoLibraryButton] (image, _) in
                guard let image = image else {return}
                DispatchQueue.main.async {
                    photoLibraryButton?.setImage(image, for: [])
                }
            }
        case .denied, .restricted, .notDetermined:
            photoLibraryButton.setImage(#imageLiteral(resourceName: "Icons_PhotoLibrary"), for: [])
        }
    }
}

extension CameraControlsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        picker.dismiss(animated: true, completion: nil)
        delegate?.photoFromPhotoLibraryWasChoosen(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.delegate?.photoLibraryPickerCancelled()
    }
}
