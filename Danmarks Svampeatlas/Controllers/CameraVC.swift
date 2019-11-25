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

protocol CameraVCDelegate: class {
    func imageReady(image: UIImage)
}

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
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
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
    
    private lazy var locationManager: LocationManager = {
       let locationManager = LocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    
    
    weak var delegate: CameraVCDelegate? = nil
    private var imagesToSave = [Data]() {
        didSet {
            locationManager.start()
        }
    }
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
            let vc = TermsController(terms: .mlPredict)
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
        super.viewWillDisappear(animated)
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
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Glyphs_Cancel"), style: .plain, target: self, action: #selector(dismiss(animated:completion:))), animated: false)
        }
        
    }
    
    
    
    internal func reset() {
        avView.alpha = 1
        cameraView.reset()
        imageView.image = nil
        avView.start()
    }
    
    private func showCameraError(error: AppError) {
        DispatchQueue.main.async {
            let backgroundView: ErrorView = {
                let view = ErrorView()
                view.translatesAutoresizingMaskIntoConstraints = false
                
                view.configure(error: error) { [unowned self] (recoveryAction) in
                    switch recoveryAction {
                    case .openSettings:
                        if let bundleId = Bundle.main.bundleIdentifier,
                            let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    default:
                        self.errorView?.removeFromSuperview()
                        self.errorView = nil
                    }
                }
                
                return view
            }()
            
            self.errorView = backgroundView
            self.view.addSubview(backgroundView)
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.avView.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: self.avView.bottomAnchor).isActive = true
        }
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
        presentVC(TermsController(terms: .cameraHelper))
    }
    
    private func createNewObservationRecord(photo: UIImage?, mushroom: Mushroom?, predictionResults: [PredictionResult]?, session: Session) {
        let newObservation = NewObservation()
        
        newObservation.mushroom = mushroom
        
        if let image = photo {
            newObservation.appendImage(image: image)
        }
        
        if let predictionResults = predictionResults {
            newObservation.predictionResultsState = .Items(predictionResults)
        }
        
        self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: AddObservationVC(newObservation: newObservation, session: session)))
    }
}


extension CameraVC: CameraViewDelegate {
    func panGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .cancelled:
            print("Cancelled")
        case .changed:
            print(gesture.translation(in: cameraView))
        default: break
        }
    }
    
    func captureButtonPressed() {
        avView.capturePhoto()
    }
    
    func usePhotoPressed() {
        guard let image = imageView.image else {return}
        
        switch usage {
        case .imageCapture:
            delegate?.imageReady(image: image)
            dismiss(animated: true, completion: nil)
        case .newObservationRecord(session: let session):
            createNewObservationRecord(photo: image, mushroom: nil, predictionResults: nil, session: session)
        case .mlPredict:
            return
        }
    }
    
    func noPhotoPressed() {
        guard case .newObservationRecord(session: let session) = usage else {return}
        createNewObservationRecord(photo: nil, mushroom: nil, predictionResults: nil, session: session)
    }
    
    func photoLibraryImagePicked(image: UIImage) {
        avView.stop()
        
        switch usage {
        case .mlPredict:
            avView.alpha = 0
            imageView.image = image
            
            DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
                switch result {
                case .Error(let error):
                    self?.cameraView.showError(error: error)
                case .Success(let predictions):
                    self?.cameraView.showResults(results: predictions)
                }
            }
            
        case .imageCapture:
            delegate?.imageReady(image: image)
            dismiss(animated: false, completion: nil)
        case .newObservationRecord(session: let session):
            createNewObservationRecord(photo: image, mushroom: nil, predictionResults: nil, session: session)
        }
    }
    
    func expandView() {
        cameraViewTopConstraint.constant = ( -avView.frame.height / 4) * 3
    }
    
    func collapseView() {
        cameraViewTopConstraint.constant = 0
    }
    
    
    func retry() {
        resetSession()
    }
    
    func mushroomSelected(predictionResult: PredictionResult, predictionResults: [PredictionResult]) {
        switch usage {
        case .mlPredict(session: let session):
            if let session = session {
                pushVC(vc: DetailsViewController(detailsContent: .mushroom(mushroom: predictionResult.mushroom, session: session, takesSelection: (selected: false, title: "Nyt fund", handler: { (selected) in
                    self.createNewObservationRecord(photo: self.imageView.image, mushroom: predictionResult.mushroom, predictionResults: predictionResults, session: session)
                }))))
            } else {
                pushVC(vc: DetailsViewController(detailsContent: .mushroom(mushroom: predictionResult.mushroom, session: session, takesSelection: nil)))
            }
        default: return
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        avView.stop()
        self.present(vc, animated: true, completion: nil)
    }
    
    func resetSession() {
        reset()
    }
    
    func pushVC(vc: UIViewController) {
        avView.stop()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleImage(_ image: UIImage) {
        switch usage {
        case .imageCapture:
            avView.alpha = 0
            imageView.image = image
            cameraView.askForConfirmation()
        case .mlPredict:
            imageView.image = image
            avView.alpha = 0
            DataService.instance.getImagePredictions(image: image) { [weak self] (result) in
                switch result {
                case .Error(let error):
                    self?.cameraView.showError(error: error)
                case .Success(let predictions):
                    self?.cameraView.showResults(results: predictions)
                }
            }
            
        case .newObservationRecord:
            imageView.image = image
            avView.alpha = 0
            cameraView.askForConfirmation()
        }
    }
}

extension CameraVC: AVViewDelegate {
    
    func error(error: AppError) {
        showCameraError(error: error)
    }
    
    func photoData(image: Data) {
        if !UserDefaultsHelper.hasBeenAskedToSaveImages {
                   ELNotificationView.appNotification(style: .action(backgroundColor: UIColor.appPrimaryColour(), actions: [
                       .positive("Ja, gem billederne", { [unowned self] in
                           UserDefaultsHelper.saveImages = true
                        self.imagesToSave.append(image)
                       }),
                       .negative("Nej", {
                           UserDefaultsHelper.saveImages = false
                       })]), primaryText: "Skal dine billeder gemmes?", secondaryText: "Hvis du er interesseret, kan vi oprette et album til de billeder du tager i denne app.", location: .top)
                       .show(animationType: .fromTop, onViewController: self)
                        UserDefaultsHelper.hasBeenAskedToSaveImages = true
               } else {
                   if UserDefaultsHelper.saveImages {
                    imagesToSave.append(image)
                    elPhotos.saveImage(photoData: image, inAlbum: "Svampeatlas")
                   }
               }
    }
}

extension CameraVC: ELPhotosManagerDelegate {
    func error(_ error: ELPhotos.ELPhotosError) {
             ELNotificationView.appNotification(style: .error(actions: [.neutral(error.recoveryAction?.rawValue, {
                       switch error.recoveryAction {
                       case .openSettings: UIApplication.openSettings()
                       default: return
                       }
                   })]), primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .top).show(animationType: .fromTop)
        }
}

extension CameraVC: LocationManagerDelegate {
    func locationInaccessible(error: LocationManager.LocationManagerError) {}
    func locationRetrieved(location: CLLocation) {
        
        print("Location Received")
        imagesToSave.forEach({ elPhotos.saveImage(photoData: $0, inAlbum: "Svampeatlas") })
    }
}
