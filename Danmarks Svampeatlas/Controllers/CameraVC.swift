//
//  RecognizeVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision
import ELKit

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
       let view = CameraView(cameraVCUsage: self.cameraVCUsage)
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
        
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), for: [])
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 31).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var exitButton: UIButton = {
      let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Glyphs_Cancel"), for: [])
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var backroundView: BackgroundView?
    
    weak var delegate: CameraVCDelegate? = nil
    
    private var cameraVCUsage: Usage
    private var cameraViewTopConstraint = NSLayoutConstraint()
    
    init(cameraVCUsage: Usage) {
        self.cameraVCUsage = cameraVCUsage
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
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if case .mlPredict = cameraVCUsage, !UserDefaultsHelper.hasAcceptedmagePredictionTerms {
                let vc = TermsController(terms: .mlPredict)
                presentVC(vc)
            
            vc.wasDismissed = { [weak self] in
                    self?.avView.start()
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
        
        switch cameraVCUsage {
        case .mlPredict, .newObservationRecord:
            view.addSubview(menuButton)
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        case .imageCapture:
            view.addSubview(exitButton)
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
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
              let backgroundView = BackgroundView()
                  backgroundView.configure(mainTitle: error.errorTitle, secondaryTitle: error.errorDescription) {
                                     if let bundleId = Bundle.main.bundleIdentifier,
                                         let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                                         UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                     }
                  }
            self.view.addSubview(backgroundView)
                  backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    @objc private func menuButtonTapped() {
        switch cameraVCUsage {
        case .mlPredict, .newObservationRecord:
            self.eLRevealViewController()?.toggleSideMenu()
        case .imageCapture:
            self.dismiss(animated: true, completion: nil)
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
    func captureButtonPressed() {
        avView.capturePhoto()
    }
    
    func usePhotoPressed() {
        guard let image = imageView.image else {return}
        
        switch cameraVCUsage {
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
        guard case .newObservationRecord(session: let session) = cameraVCUsage else {return}
        createNewObservationRecord(photo: nil, mushroom: nil, predictionResults: nil, session: session)
    }
    
    func photoLibraryImagePicked(image: UIImage) {
        avView.stop()
        
        switch cameraVCUsage {
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
         switch cameraVCUsage {
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
}

extension CameraVC: AVViewDelegate {
    
    func error(error: AppError) {
        showCameraError(error: error)
    }
    
    func photo(image: UIImage) {
        switch cameraVCUsage {
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
//                    self?.results = predictions
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
