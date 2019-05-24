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

protocol CameraVCDelegate: class {
    func imageReady(image: UIImage)
}

class CameraVC: UIViewController {
    
    enum CameraVCUsage {
        case mlPredict
        case imageCapture
        case newObservationRecord(session: Session)
        case tempNewObservationRecord(session: Session)
    }
    
    enum CameraRotation {
        case portrait
        case landscapeLeft
        case landscapeRight
    }
    
//    private var appMenuBar: AppNavigationBar = {
//        let view = AppNavigationBar(navigationBarType: .transparent)
//       view.translatesAutoresizingMaskIntoConstraints = false
//        view.setLeftItem(itemType: AppNavigationBar.ItemType.menuButton)
//        return view
//    }()
    
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
        button.setImage(#imageLiteral(resourceName: "MenuButton"), for: [])
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
        button.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var cameraVCUsage: CameraVCUsage
    weak var delegate: CameraVCDelegate? = nil
   
    init(cameraVCUsage: CameraVCUsage) {
        self.cameraVCUsage = cameraVCUsage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.eLRevealViewController()?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    deinit {
        debugPrint("CameraVC was deinited")
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black
        view.addSubview(avView)
        avView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        avView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        avView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        avView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    
        view.addSubview(cameraView)
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraView.topConstraint = cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        cameraView.topConstraint.isActive = true
        
        
        switch cameraVCUsage {
        case .mlPredict, .newObservationRecord, .tempNewObservationRecord:
            view.addSubview(menuButton)
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        case .imageCapture:
            view.addSubview(exitButton)
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        }
//
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        
//        view.addSubview(appMenuBar)
//        appMenuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        appMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        appMenuBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        appMenuBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        return
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        switch UIDevice.current.orientation {
//        case .landscapeLeft:
//            self.previewLayer.connection?.videoOrientation = .landscapeRight
//        case .landscapeRight:
//            self.previewLayer.connection?.videoOrientation = .landscapeLeft
//        case .portrait:
//            self.previewLayer.connection?.videoOrientation = .portrait
//        case .portraitUpsideDown:
//            self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
//        default:
//            break
//        }
//        coordinator.animate(alongsideTransition: { (context) in
//            self.previewLayer.frame = self.cameraView.frame
//        }) { (_) in
//
//        }
//    }

    
    private func reset() {
        cameraView.reset()
        imageView.image = nil
        avView.start()
    }
    
    private func showCameraError() {
        let backgroundView = BackgroundView()
        view.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc private func menuButtonTapped() {
        switch cameraVCUsage {
        case .mlPredict, .tempNewObservationRecord:
            self.eLRevealViewController()?.toggleSideMenu()
        case .newObservationRecord, .imageCapture:
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
    
    private func createNewObservationRecord(photo: UIImage?, mushroom: Mushroom?, session: Session) {
        let newObservation = NewObservation()
         newObservation.mushroom = mushroom
        
        if let image = photo {
              newObservation.images.append(image)
        }
    
        self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: AddObservationVC(newObservation: newObservation, session: session)))
    }
}


extension CameraVC: CameraViewDelegate {
    func noPhotoButtonPressed() {
        if case .tempNewObservationRecord(session: let session) = cameraVCUsage {
            createNewObservationRecord(photo: nil, mushroom: nil, session: session)
        }
    }
    
    func captureButtonPressed() {
        avView.capturePhoto()
    }
    
    func photoFromPhotoLibraryWasChoosen(image: UIImage) {
        avView.stop()

        
        switch cameraVCUsage {
        case .imageCapture:
            delegate?.imageReady(image: image)
            dismiss(animated: false, completion: nil)
        case .newObservationRecord, .mlPredict:
            imageView.image = image            
        case .tempNewObservationRecord(session: let session):
            createNewObservationRecord(photo: image, mushroom: nil, session: session)
        }
    }
    
    func photoLibraryPickerCancelled() {
        avView.start()
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
        return
    }
    
    func photo(image: UIImage) {
        switch cameraVCUsage {
        case .imageCapture:
            delegate?.imageReady(image: image)
            dismiss(animated: false, completion: nil)
        case .newObservationRecord, .mlPredict:
            imageView.image = image
        case .tempNewObservationRecord(session: let session):
            createNewObservationRecord(photo: image, mushroom: nil, session: session)
        }
    }
}

extension CameraVC: ELRevealViewControllerDelegate {
    func isAllowedToPushMenu() -> Bool? {
        return true
    }
    
    func isAllowedToRotate() -> Bool? {
        return true
    }
}
