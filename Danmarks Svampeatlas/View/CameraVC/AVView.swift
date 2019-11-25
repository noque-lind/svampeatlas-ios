//
//  AVView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 05/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

//
//  AVView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 05/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

//class AVView: UIView {
//
//
//
//
//    private lazy var captureSession: AVCaptureSession = {
//        let session = AVCaptureSession()
//        session.sessionPreset = AVCaptureSession.Preset.photo
//        return session
//    }()
//
//    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
//       let layer = AVCaptureVideoPreviewLayer()
//        layer.videoGravity = .resize
//        return layer
//    }()
//
//    private var heightConstraint = NSLayoutConstraint()
//    private var widthConstraint = NSLayoutConstraint()
//
//    private var focusFrame: UIImageView?
//
//    private var backCamera: AVCaptureDevice?
//
//    weak var delegate: AVViewDelegate?
//    var orientation: CameraVC.CameraRotation = .portrait
//    private var cameraOutput: AVCapturePhotoOutput?
//
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let res = getCaptureResolution()
//        let newHeight = (res.width / res.height) * UIScreen.main.bounds.width
//        if newHeight > 1 {
//            heightConstraint.constant = newHeight
//        }
//
//        previewLayer.frame = self.bounds
//    }
//
//    init() {
//        super.init(frame: CGRect.zero)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError()
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchPoint = touches.first! as UITouch
//        let screenSize = bounds.size
//        let focusPoint = CGPoint(x: touchPoint.location(in: self).y / screenSize.height, y: 1.0 - touchPoint.location(in: self).x / screenSize.width)
//
//        if let camera = backCamera {
//            do {
//                try camera.lockForConfiguration()
//                if camera.isFocusPointOfInterestSupported {
//                    camera.focusPointOfInterest = focusPoint
//                    camera.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
//                }
//                if camera.isExposurePointOfInterestSupported {
//                    camera.exposurePointOfInterest = focusPoint
//                    camera.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
//                }
//                camera.unlockForConfiguration()
//                setFocusFrame(point: focusPoint)
//            } catch {
//                // Handle errors here
//            }
//        }
//    }
//
//
//    func setup() {
//        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
//            backCamera = AVCaptureDevice.default(for: AVMediaType.video)
//                guard let backCamera = backCamera else {return}
//            do {
//                    try self.addCameraInput(device: backCamera)
//                    try self.createCameraOutput()
//                     layer.addSublayer(self.previewLayer)
//
//
//                DispatchQueue.global().async {
//                        self.captureSession.startRunning()
//
//                    DispatchQueue.main.async {
//                        self.previewLayer.session = self.captureSession
//                    }
//                }
//                } catch {
//                    delegate?.error(error: Error.permissionsError)
//                }
//        } else {
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
//               if granted == true {
//                self.setup()
//               } else {
//                self.delegate?.error(error: Error.permissionsError)
//               }
//           })
//        }
//    }
//
//    private func setupView() {
//        backgroundColor = UIColor.clear
//        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
//        heightConstraint.isActive = true
//        setup()
//    }
//
//    private func addCameraInput(device: AVCaptureDevice) throws {
//        let input = try AVCaptureDeviceInput(device:device)
//        if captureSession.canAddInput(input) == true {
//            captureSession.addInput(input)
//        } else {
//            throw NSError.init(domain: "Input error", code: 1, userInfo: nil)
//        }
//    }
//
//    private func createCameraOutput() throws {
//        cameraOutput = AVCapturePhotoOutput()
//        if captureSession.canAddOutput(cameraOutput!) == true {
//            captureSession.addOutput(cameraOutput!)
//        } else {
//            throw NSError.init(domain: "Output Error", code: 1, userInfo: nil)
//        }
//    }
//
//    func start() {
//        if !captureSession.inputs.isEmpty {
//            setup()
//        } else {
//            DispatchQueue.global().async {
//                self.captureSession.startRunning()
//            }
//        }
//    }
//
//    func stop() {
//        DispatchQueue.global().async {
//            self.captureSession.stopRunning()
//        }
//    }
//
////    func setFullScreen(_ fullScreen: Bool) {
////        if fullScreen {
////            captureSession.sessionPreset = .high
////        } else {
////            captureSession.sessionPreset = .photo
////        }
////
////        layoutSubviews()
////    }
//
//    private func getCaptureResolution() -> CGSize {
//        // Define default resolution
//        var resolution = CGSize(width: 0, height: 0)
//
//        // Get cur video device
//        let curVideoDevice = backCamera
//
//        // Get video dimensions
//        if let formatDescription = curVideoDevice?.activeFormat.formatDescription {
//            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
//            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
//        }
//
//        // Return resolution
//        return resolution
//    }
//
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//
//        switch orientation {
//        case .portrait:
//            cameraOutput?.connection(with: .video)?.videoOrientation = .portrait
//        case .landscapeLeft:
//            cameraOutput?.connection(with: .video)?.videoOrientation = .landscapeRight
//        case .landscapeRight:
//            cameraOutput?.connection(with: .video)?.videoOrientation = .landscapeLeft
//        }
//
//        cameraOutput?.capturePhoto(with: settings, delegate: self)
//    }
//
//    private func setFocusFrame(point: CGPoint) {
//        focusFrame?.removeFromSuperview()
//        focusFrame = nil
//
//        let focusFrame: UIImageView = {
//           let view = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 100))
//            view.image = #imageLiteral(resourceName: "Icons_Utils_FocusFrame")
//            view.alpha = 0
//            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//            return view
//        }()
//
//        self.focusFrame = focusFrame
//        addSubview(focusFrame)
//        focusFrame.center = CGPoint(x: bounds.width * (1 - point.y), y: bounds.height * point.x)
//
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
//            focusFrame.alpha = 1
//            focusFrame.transform = CGAffineTransform.identity
//        }) { (_) in
//            focusFrame.removeFromSuperview()
//            self.focusFrame = nil
//        }
//    }
//}
//
//extension AVView: AVCapturePhotoCaptureDelegate {
//    override func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//
//    }
//}



import UIKit
import AVFoundation

protocol AVViewDelegate: class {
    func error(error: AppError)
    func photoData(image: Data)
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
                    
                    DispatchQueue.main.async {
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
            DispatchQueue.main.async {
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
        settings.metadata = [String(kCGImagePropertyGPSDictionary):  [String( kCGImagePropertyGPSLatitude): 12.6107, String(kCGImagePropertyGPSLongitude): 55.6886]]
        
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
    
        
        if let error = error {
            debugPrint(error)
        } else {
            DispatchQueue.main.async {
                if let imageData = photo.fileDataRepresentation() {
                    self.delegate?.photoData(image: imageData)
                    self.captureSession.stopRunning()
                }
            }
        }
    }
}
