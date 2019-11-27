//
//  AVView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 05/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import AVFoundation

protocol AVViewDelegate: class {
    func error(error: AppError)
    func photoData(_ photoData: Data)
}

class AVView: UIView {
    
    enum AVViewError: AppError {
        var recoveryAction: RecoveryAction? {
            switch self {
            case .permissionsError:
                return .openSettings
            default: return nil
            }
        }
        
        var errorDescription: String {
            switch self {
            case .cameraError(let error): return "\(error.localizedDescription)"
            case .permissionsError: return"Du kan give appen tilladelse til at bruge kameraet i indstillinger."
            }
        }
        
        var errorTitle: String {
            switch self {
            case .permissionsError:
                return"Manglende tilladelse"
            case .cameraError:
                return "Kamera fejl"
            }
        }
        
        case permissionsError
        case cameraError(error: Error)
    }
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        return session
    }()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resize
        return layer
    }()
    
    weak var delegate: AVViewDelegate?
    var orientation: CameraVC.CameraRotation = .portrait
    
    private var focusFrame: UIImageView?
    private var camera: AVCaptureDevice?
    private var input: AVCaptureInput?
    private var output: AVCapturePhotoOutput?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.bounds
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let input = camera, let touchPoint = touches.first else {return}
        let focusPoint = CGPoint(x: touchPoint.location(in: self).y / bounds.height, y: 1.0 - touchPoint.location(in: self).x / bounds.width)
        
        do {
            try? input.lockForConfiguration()
            if input.isFocusPointOfInterestSupported {
                input.focusPointOfInterest = focusPoint
                input.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            }
            
            if input.isExposurePointOfInterestSupported {
                input.exposurePointOfInterest = focusPoint
                input.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            }
            
            input.unlockForConfiguration()
            setFocusFrame(point: focusPoint)
        }
    }
    
    private func setupView() {
        clipsToBounds = true
    }
    
    private func configure() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            do {
                if let camera = AVCaptureDevice.default(for: .video) {
                    self.camera = camera
                    try self.addInput(device: camera)
                    try self.addOutput()
                    layer.addSublayer(previewLayer)
                    
                    DispatchQueue.global(qos: .default).async {
                        self.captureSession.startRunning()
                        self.previewLayer.session = self.captureSession
                    }
                }
            } catch {
                delegate?.error(error: AVViewError.cameraError(error: error))
            }
            
            
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                DispatchQueue.main.async {
                    if granted {
                        self.configure()
                    } else {
                        self.delegate?.error(error: AVViewError.permissionsError)
                    }
                }
                
            })
        }
    }
    
    private func addInput(device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) == true {
            captureSession.addInput(input)
            self.input = input
        }
    }
    
    private func addOutput() throws {
        output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output!) == true {
            captureSession.addOutput(output!)
        }
    }
    
    func start() {
        if !captureSession.outputs.isEmpty && !captureSession.inputs.isEmpty {
            DispatchQueue.global(qos: .default).async {
                self.captureSession.startRunning()
                self.previewLayer.session = self.captureSession
            }
        } else {
            configure()
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        //        settings.metadata = [String(kCGImagePropertyGPSDictionary):  [String( kCGImagePropertyGPSLatitude): 12.6107, String(kCGImagePropertyGPSLongitude): 55.6886]]
        
        switch orientation {
        case .portrait:
            output?.connection(with: .video)?.videoOrientation = .portrait
        case .landscapeLeft:
            output?.connection(with: .video)?.videoOrientation = .landscapeRight
        case .landscapeRight:
            output?.connection(with: .video)?.videoOrientation = .landscapeLeft
        }
        
        output?.capturePhoto(with: settings, delegate: self)
    }
    
    private func setFocusFrame(point: CGPoint) {
        focusFrame?.removeFromSuperview()
        focusFrame = nil
        
        let focusFrame: UIImageView = {
            let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 100))
            view.image = #imageLiteral(resourceName: "Icons_Utils_FocusFrame")
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            return view
        }()
        
        self.focusFrame = focusFrame
        addSubview(focusFrame)
        focusFrame.center = CGPoint(x: bounds.width * (1 - point.y), y: bounds.height * point.x)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            focusFrame.alpha = 1
            focusFrame.transform = CGAffineTransform.identity
        }) { (_) in
            focusFrame.removeFromSuperview()
            self.focusFrame = nil
        }
    }
}

extension AVView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.delegate?.error(error: AVViewError.cameraError(error: error))
            } else {
                if let imageData = photo.fileDataRepresentation() {
                    self.delegate?.photoData(imageData)
                    self.captureSession.stopRunning()
                }
            }
        }
    }
}
