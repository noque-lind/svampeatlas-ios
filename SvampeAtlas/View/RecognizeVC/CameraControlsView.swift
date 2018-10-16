//
//  CameraControlsVieew.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol CameraControlsViewDelegate: class {
    func capturePhoto()
    func presentVC(_ vc: UIViewController)
    func photoFromPhotoLibraryWasChoosen(image: UIImage)
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
    
    lazy var photoLibraryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 8
        button.layer.shadowOpacity = 0.5
        button.addTarget(self, action: #selector(photoLibraryButtonPressed), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        return button
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = UIColor.appWhite()
        view.alpha = 0
        return view
    }()
    
    weak var delegate: CameraControlsViewDelegate? = nil
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
       backgroundColor = UIColor.clear
        
        addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        captureButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
//        addSubview(photoLibraryButton)
//        photoLibraryButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        photoLibraryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        
    }
    
    @objc func captureButtonPressed() {
        delegate?.capturePhoto()
        
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
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        delegate?.presentVC(picker)
    }

    func removeActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.alpha = 0
    }
    
    func reset() {
        captureButton.alpha = 1
        photoLibraryButton.alpha = 1
    }
    
    func shouldHideCameraButton() {
        
    }
}

extension CameraControlsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {return}
        photoLibraryButton.alpha = 0
        captureButton.alpha = 0
        delegate?.photoFromPhotoLibraryWasChoosen(image: image)
    }
}



//class ELPhotoLibraryController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    var delegate: PhotoServiceDelegate? = nil
//    
//    let picker = UIImagePickerController()
//    
//    
//    func showMediaOptions() {
//        picker.delegate = self
//        
//        let alert = UIAlertController(title: "Vælg et profilbillede til din hund", message: "", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Tag et nyt billede", style: .default, handler: { (action) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                self.picker.allowsEditing = true
//                self.picker.sourceType = UIImagePickerControllerSourceType.camera
//                self.picker.cameraCaptureMode = .photo
//                self.picker.modalPresentationStyle = .fullScreen
//                self.delegate?.showPickedMediaType(controller: self.picker)
//            } else {
//                //            Device has no camera
//            }
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Vælg et fra mit bibliotek", style: .default, handler: { (action) in
//            self.picker.allowsEditing = true
//            self.picker.sourceType = .photoLibrary
//            self.delegate?.showPickedMediaType(controller: self.picker)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        delegate?.showMediaOptions(alertController: alert)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            self.delegate?.mediaWasPicked(pickedImage: image)
//            self.picker.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    
//    
//}
    
  

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
