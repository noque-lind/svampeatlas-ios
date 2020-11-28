//
//  RecognizeVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import ELKit
import CoreLocation
import Foundation
import Photos

class CameraVC: UIViewController {
    
    enum Usage {
        case mlPredict(session: Session?)
        case imageCapture
        case newObservationRecord(session: Session)
    }
    
    enum CameraRotation {
        case portrait
        case landscapeLeft
        case landscapeRight
    }
    
    private lazy var cameraView: CameraView = {
        let view = CameraView(cameraVCUsage: self.usage)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var avView: AVView = {
        let view = AVView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var imageView: DownloadableImageView = {
        let view = DownloadableImageView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var elPhotos: ELPhotos = {
       let photos = ELPhotos()
        photos.delegate = self
        return photos
    }()
    
    var onImageCaptured: ((URL) -> ())?
    
    private var currentImageURL: URL?
    private let usage: Usage
    private var errorView: ErrorView?
    private var cameraViewTopConstraint = NSLayoutConstraint()
    
    init(cameraVCUsage: Usage) {
        self.usage = cameraVCUsage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        navigationController?.appConfiguration(translucent: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if case .mlPredict = usage, !UserDefaultsHelper.hasAcceptedmagePredictionTerms {
            let vc = TermsVC(terms: .mlPredict)
            presentVC(vc)
            
            vc.wasDismissed = { [unowned avView] in
                avView.start()
            }
            
        } else {
            avView.start()
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    

    private func setupView() {
        view.backgroundColor = UIColor.black
        view.addSubview(avView)
        
        avView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        avView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        avView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        avView.heightAnchor.constraint(equalTo: avView.widthAnchor, multiplier: 1.3333333333333).isActive = true
        
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(cameraView)
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraViewTopConstraint = cameraView.topAnchor.constraint(equalTo: avView.bottomAnchor)
        cameraViewTopConstraint.isActive = true
        
        switch usage {
        case .mlPredict, .newObservationRecord:
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
            navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_About"), style: .plain, target: self, action: #selector(informationButtonPressed)), animated: false)
        case .imageCapture:
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Glyphs_Cancel"), style: .plain, target: self, action: #selector(onDismissPressed)), animated: false)
        }
    }
    
    @objc private func onDismissPressed() {
        avView.stop()
        
        if let imageURL = currentImageURL {
            ELFileManager.deleteImage(imageURL: imageURL)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    internal func reset() {
        avView.isHidden = false
        imageView.isHidden = false
        imageView.image = nil
        cameraView.reset()
        avView.start()
        
        if let imageURL = currentImageURL {
            ELFileManager.deleteImage(imageURL: imageURL)
        }
    }
    
    private func showCameraError(error: AppError) {
            let errorView: ErrorView = {
                let view = ErrorView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.configure(error: error) { [unowned self] (recoveryAction) in
                    switch recoveryAction {
                    case .openSettings:
                        UIApplication.openSettings()
                    default:
                        self.errorView?.removeFromSuperview()
                        self.errorView = nil
                        self.reset()
                    }
                }
                
                return view
            }()
          
            imageView.isHidden = true
            avView.isHidden = true
            self.errorView = errorView
            view.addSubview(errorView)
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            errorView.topAnchor.constraint(equalTo: avView.topAnchor).isActive = true
            errorView.bottomAnchor.constraint(equalTo: avView.bottomAnchor).isActive = true
    }
    
    @objc private func orientationDidChange() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            cameraView.orientation = .landscapeLeft
            avView.orientation = .landscapeLeft
        case .landscapeRight:
            cameraView.orientation = .landscapeRight
            avView.orientation = .landscapeRight
        default:
            cameraView.orientation = .portrait
            avView.orientation = .portrait
        }
    }
    
    @objc private func informationButtonPressed() {
        presentVC(TermsVC(terms: .cameraHelper))
    }
    
    private func handleImageSaving(photoData: Data) {
        if !UserDefaultsHelper.hasBeenAskedToSaveImages {
            ELNotificationView.appNotification(style: .action(backgroundColor: UIColor.appPrimaryColour(), actions: [
                .positive(NSLocalizedString("cameraVC_shouldSaveImagesPrompt_message_positive", comment: ""), { [unowned elPhotos] in
                    UserDefaultsHelper.saveImages = true
                    elPhotos.saveImage(photoData: photoData, inAlbum: Utilities.PHOTOALBUMNAME)
                }),
                .negative(NSLocalizedString("cameraVC_shouldSaveImagesPrompt_message_negative", comment: ""), {
                    UserDefaultsHelper.saveImages = false
                })]), primaryText: NSLocalizedString("cameraVC_shouldSaveImagesPrompt_title", comment: ""), secondaryText: NSLocalizedString("cameraVC_shouldSaveImagesPrompt_message", comment: ""), location: .top)
                .show(animationType: .fromTop, onViewController: self)
                 UserDefaultsHelper.hasBeenAskedToSaveImages = true
        } else {
            if UserDefaultsHelper.saveImages {
                elPhotos.saveImage(photoData: photoData, inAlbum: Utilities.PHOTOALBUMNAME)
            }
        }
    }
    
    private func getPredictions(imageURL: URL) {
        guard let image = UIImage.init(url: imageURL) else {return}
           DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
               switch result {
               case .failure(let error):
                   self?.cameraView.showError(error: error)
               case .success(let predictions):
                   self?.cameraView.showResults(results: predictions)
               }
           }
       }
    
    private func createNewObservationRecord(imageURL: URL?, mushroom: Mushroom?, predictionResults: [PredictionResult]?, session: Session) {
        
        // When CameraVC is in the context of creating a newObservation Record and show the AddObservationVC.
        
        let vm = AddObservationViewModel(action: .new, session: session)
        
        if let mushroom = mushroom {
            vm.mushroom = mushroom
        }
        
        if let imageURL = imageURL {
            vm.addImage(newObservationImage: NewObservationImage(type: .new, url: imageURL))
        }
        if let predictionResults = predictionResults {
            vm.predictionResults.value = .items(items: predictionResults)
        }
        

        self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: AddObservationVC.init(viewModel: vm)))
    }
    
    private func handleImage(_ url: URL) {
        // Whether the image comes from the photo library or is a newly captured image, this function gets called. This function should ensure that the image is shown to the user, and the correct things happen depending on the context.
        
        currentImageURL = url
        avView.isHidden = true
        imageView.loadImage(url: url)
        switch usage {
        case .imageCapture: cameraView.setCameraControlsState(state: .confirmation)
        case .mlPredict:
            getPredictions(imageURL: url)
            cameraView.setCameraControlsState(state: .loading)
        case .newObservationRecord: cameraView.setCameraControlsState(state: .confirmation)
        }
    }
}


extension CameraVC: CameraViewDelegate {
    func move(expanded: Bool) {
        cameraViewTopConstraint.constant = expanded ? ( -avView.frame.height / 4) * 3: 0
    }
    
    func photoLibraryButtonPressed(state: CameraControlsView.State) {
        switch state {
        case .confirmation: reset()
        case .regular:
            avView.stop()
            elPhotos.showPhotoLibrary()
        default: return
        }
    }
    
    func textButtonPressed(state: CameraControlsView.State) {
        avView.stop()
        
        switch state {
        case .confirmation:
            if let imageURL = currentImageURL {
                switch usage {
                case .imageCapture:
                    onImageCaptured?(imageURL)
                    dismiss(animated: true, completion: nil)
                case .newObservationRecord(session: let session):
                    createNewObservationRecord(imageURL: imageURL, mushroom: nil, predictionResults: nil, session: session)
                case .mlPredict: return
                }
            }
        case .regular:
            guard case .newObservationRecord(session: let session) = usage else {return}
            createNewObservationRecord(imageURL: nil, mushroom: nil, predictionResults: nil, session: session)
        default: return
        }
    }
       
    func captureButtonPressed() {
        cameraView.setCameraControlsState(state: .loading)
        avView.capturePhoto()
    }
    
    func retry() {
        reset()
    }
    
    func mushroomSelected(predictionResult: PredictionResult, predictionResults: [PredictionResult]) {
        switch usage {
        case .mlPredict(session: let session):
            if let session = session {
                navigationController?.pushViewController(DetailsViewController(detailsContent: .mushroom(mushroom: predictionResult.mushroom), session: session, takesSelection: (selected: false, title: NSLocalizedString("detailsVC_newSightingPrompt", comment: ""), handler: { [unowned self] (selected) in
                    self.createNewObservationRecord(imageURL: self.currentImageURL, mushroom: predictionResult.mushroom, predictionResults: predictionResults, session: session)
                })), animated: true)
                
            } else {
                navigationController?.pushViewController(DetailsViewController(detailsContent: .mushroom(mushroom: predictionResult.mushroom), session: nil), animated: true)
            }
        default: return
        }
    }
}

extension CameraVC: AVViewDelegate {
    func error(error: AVView.AVViewError) {
        // Whenever there's an error with the AVView, AKA. the starting and stopping of camera and image capture, an error should be shown on the screen. This error is fatal to the continuation, hence it should replace AVView with an ErrorView.
        
        showCameraError(error: error)
    }
    
    func photoData(_ photoData: Data) {
        // Whenever a photo is taken, the data for whatever the AVView returns is given here. From here we save that data in a temporary location on device. Temporary files are not purged for the lifetime off the app, but should nevertheless be deleted when no longer needed. Whenever an image is saved, we want to see if the user wants it saved to their photoalbum.
        
        handleImageSaving(photoData: photoData)
        
        switch ELFileManager.saveTempImage(imageData: photoData) {
        case .success(let url):
            handleImage(url)
        case .failure(let error):
            showCameraError(error: error)
        }
    }
}

extension CameraVC: ELPhotosManagerDelegate {
    
    func presentVC(_ vc: UIViewController) {
        // To present the photolibrary VC
        present(vc, animated: true, completion: nil)
    }
    
    func assetFetched(_ imageURL: URL) {
        // When the user selects an image from their photoalbum we retrieve the URL for that image, and use that as the referencing point.
        
        handleImage(imageURL)
    }
    
   func assetFetchCanceled() {
        
        // If the user cancelled the photolibrary fetch the session should reset.
        reset()
    }
    
    func error(_ error: ELPhotos.ELPhotosError) {
        
        // If the user has choosen to save images to the photo library, but haven't allowed the app access, this error will show every time they take an image. This error is not fatal, hence shown as a notification.
        
        ELNotificationView.appNotification(style: .error(actions: [.neutral(error.recoveryAction?.localizableText, {
                       switch error.recoveryAction {
                       case .openSettings: UIApplication.openSettings()
                       default: return
                       }
                })]), primaryText: error.title, secondaryText: error.message, location: .top)
                .show(animationType: .fromTop)
        }
}
