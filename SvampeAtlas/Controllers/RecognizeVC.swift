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

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var viewdidappearProcessed = false
    
    var photoData: Data?
    
    @IBOutlet weak var recognizeView: RecognizeView!
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
setupView()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            previewLayer.frame = cameraView.frame
    }
    override func viewWillAppear(_ animated: Bool) {
        if !viewdidappearProcessed {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            
            let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera!)
                if captureSession.canAddInput(input) == true {
                    captureSession.addInput(input)
                }
                
                cameraOutput = AVCapturePhotoOutput()
                if captureSession.canAddOutput(cameraOutput) == true {
                    captureSession.addOutput(cameraOutput!)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    previewLayer.connection?.videoOrientation = .portrait
                    
                    cameraView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } catch {
                debugPrint(error)
            }
            viewdidappearProcessed = true
        }
        super.viewWillAppear(animated)
        
    }
    
    private func setupView() {
        navigationBlurEffect()
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
}


extension RecognizeVC: RecognizeViewDelegate, AVCapturePhotoCaptureDelegate {
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
        captureSession.stopRunning()
    }
    
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
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
            if classification.confidence < 0.5 {
                
            } else {
                let result = temptModel(identifier: classification.identifier, confidence: CGFloat(classification.confidence))
                print(classification)
            models.append(result)
                
            }
            recognizeView.showResults(results: models)
        }
    }
    
}
