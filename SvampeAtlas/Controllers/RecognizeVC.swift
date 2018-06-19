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
       let view = RecognizeView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var viewdidappearProcessed = false
    
    var photoData: Data?
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
            setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            previewLayer.frame = cameraView.frame
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = cameraView.frame
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        if !viewdidappearProcessed {
            
            // Creating the session
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            
            // Finding the backCamera of the device. TODO: Should make it failsafe
            let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera!)
                if captureSession.canAddInput(input) == true {
                    captureSession.addInput(input)
                }
                
                // Creating the output
                cameraOutput = AVCapturePhotoOutput()
                if captureSession.canAddOutput(cameraOutput) == true {
                    captureSession.addOutput(cameraOutput!)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    previewLayer.connection?.videoOrientation = .portrait
                    
                    cameraView.layer.addSublayer(previewLayer)
                    DispatchQueue.main.async {
                        self.captureSession.startRunning()
                    }
                }
            } catch {
                debugPrint(error)
            }
            viewdidappearProcessed = true
        }
        super.viewWillAppear(animated)
        
    }
    
    private func setupView() {
        view.addSubview(cameraView)
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(recognizeView)
        recognizeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recognizeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recognizeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        recognizeView.topConstraint = recognizeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        recognizeView.topConstraint.isActive = true
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        

//        navigationBlurEffect()
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
    
    func navigationBlurEffect() {
        // Add blur view
        self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.topItem?.title = "Arts-bestemmelse"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
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
        captureSession.startRunning()
    }
}


extension RecognizeVC: RecognizeViewDelegate, AVCapturePhotoCaptureDelegate {
    func resetSession() {
        reset()
    }
    
    func pushVC(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 227, kCVPixelBufferHeightKey as String: 227]
//        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
//        captureSession.stopRunning()
    }
    
    
    
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: mlResultHandler)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
        }
    }
    
    @available(iOS 11.0, *)
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
    
}
