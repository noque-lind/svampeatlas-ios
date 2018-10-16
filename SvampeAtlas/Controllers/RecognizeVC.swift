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

class RecognizeVC: UIViewController {

    private var recognizeView: RecognizeView = {
       let view = RecognizeView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var errorView: UIView = {
      let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.appPrimaryHightlighed()
        label.textAlignment = .center
        label.textColor = UIColor.appWhite()
        label.text = "Der skete en fejl med at få dit kamera til at fungere."
        label.numberOfLines = 0
        
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var cameraView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(cameraViewWasTapped(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)
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
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var exitButton: UIButton = {
      let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        button.widthAnchor.constraint(equalToConstant: 14).isActive = true
        button.heightAnchor.constraint(equalToConstant: 14).isActive = true
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var captureSession: AVCaptureSession?
    var cameraOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    var isObservation: Bool
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            setupView()
    }
    
    init(isObservation: Bool) {
        self.isObservation = isObservation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer?.frame = cameraView.frame
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {showCameraError(); return}
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSession.Preset.high
        
        do {
            try addCameraInput(device: backCamera)
            try createCameraOutput()
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.videoGravity = .resizeAspect
            
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                previewLayer.connection?.videoOrientation = .portrait
            } else if UIDevice.current.orientation == .landscapeLeft {
                previewLayer.connection?.videoOrientation = .landscapeLeft
            } else if UIDevice.current.orientation == .landscapeRight {
                previewLayer.connection?.videoOrientation = .landscapeRight
            }
            
            cameraView.layer.addSublayer(previewLayer)
            DispatchQueue.main.async {
                self.captureSession?.startRunning()
            }
        } catch {
            debugPrint(error)
        }
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        view.addSubview(cameraView)
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(recognizeView)
        recognizeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recognizeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recognizeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        recognizeView.topConstraint = recognizeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        recognizeView.topConstraint.isActive = true
        
        
        if isObservation {
            view.addSubview(exitButton)
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        } else {
            view.addSubview(menuButton)
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        recognizeView.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            self.previewLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            self.previewLayer.connection?.videoOrientation = .landscapeLeft
        case .portrait:
            self.previewLayer.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
        default:
            break
        }
        coordinator.animate(alongsideTransition: { (context) in
            self.previewLayer.frame = self.cameraView.frame
        }) { (_) in
            
        }
    }
    
    @objc private func cameraViewWasTapped(sender: UITapGestureRecognizer) {
        if recognizeView.isExpanded {
           reset()
        } else {
            recognizeView.cameraControlsView.captureButtonPressed()
        }
    }
    
    private func reset() {
        recognizeView.reset()
        imageView.image = nil
        captureSession?.startRunning()
    }
    
    private func showCameraError() {
        view.insertSubview(errorView, at: 0)
        errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        errorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func addCameraInput(device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device:device)
        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        } else {
            throw NSError.init(domain: "Input error", code: 1, userInfo: nil)
        }
    }
    
    private func createCameraOutput() throws {
        cameraOutput = AVCapturePhotoOutput()
        if captureSession?.canAddOutput(cameraOutput!) == true {
            captureSession?.addOutput(cameraOutput!)
        } else {
            throw NSError.init(domain: "Output Error", code: 1, userInfo: nil)
        }
    }
    
    @objc private func menuButtonTapped() {
        if isObservation {
            self.eLRevealViewController()?.pushNewViewController(viewController: NewObservationVC())
        } else {
            self.eLRevealViewController()?.toggleSideMenu()
        }
    }
}


extension RecognizeVC: RecognizeViewDelegate {
    func photoFromPhotoLibraryWasChoosen(image: UIImage) {
        captureSession?.stopRunning()
        imageView.image = image
        if let cgImage = image.cgImage {
            processImage(cgImage, model: SqueezeNet().model)
        }
    }
    
    func presentVC(vc: UIViewController) {
        captureSession?.stopRunning()
        self.present(vc, animated: true, completion: nil)
    }
    
    func resetSession() {
        reset()
    }
    
    func pushVC(vc: UIViewController) {
        captureSession?.stopRunning()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 227, kCVPixelBufferHeightKey as String: 227]
//        settings.previewPhotoFormat = previewFormat
        
        cameraOutput?.capturePhoto(with: settings, delegate: self)
//        captureSession.stopRunning()
    }
}

extension RecognizeVC: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession?.stopRunning()
        if let error = error {
            debugPrint(error)
        } else {
            if let imageData = photo.fileDataRepresentation() {
                if let image = UIImage.init(data: imageData) {
                    if let cgImage = image.cgImage {
                        processImage(cgImage, model: SqueezeNet().model)
                    }
                }
            }
            
        }
    }

    
    func mlResultHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {return}
        var models = [temptModel]()
        
        for classification in results {
            if classification.confidence < 0.1 {
                
            } else {
                let result = temptModel(identifier: classification.identifier, confidence: CGFloat(classification.confidence))
                print(classification)
            models.append(result)
            }
        }
        recognizeView.showResults(results: models)
    }
    
    
    
    private func processImage(_ image: CGImage, model: MLModel) {
        do {
            let model = try VNCoreMLModel(for: SqueezeNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: mlResultHandler)
            let handler = VNImageRequestHandler(cgImage: image)
            try handler.perform([request])
        } catch {
            debugPrint(error)
        }
    }
}
