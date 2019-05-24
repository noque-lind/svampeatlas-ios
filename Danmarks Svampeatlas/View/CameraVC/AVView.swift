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
    func photo(image: UIImage)
}

class AVView: UIView {
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        return session
    }()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    weak var delegate: AVViewDelegate?
    var orientation: CameraVC.CameraRotation = .portrait
    private var cameraOutput: AVCapturePhotoOutput?
    
    
    
    
    override func layoutSubviews() {
        previewLayer.frame = self.bounds
        super.layoutSubviews()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func setupView() {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        
        do {
            try addCameraInput(device: backCamera)
            try createCameraOutput()
            layer.addSublayer(previewLayer)
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func addCameraInput(device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device:device)
        if captureSession.canAddInput(input) == true {
            captureSession.addInput(input)
        } else {
            throw NSError.init(domain: "Input error", code: 1, userInfo: nil)
        }
    }
    
    private func createCameraOutput() throws {
        cameraOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(cameraOutput!) == true {
            captureSession.addOutput(cameraOutput!)
        } else {
            throw NSError.init(domain: "Output Error", code: 1, userInfo: nil)
        }
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        switch orientation {
        case .portrait:
            cameraOutput?.connection(with: .video)?.videoOrientation = .portrait
        case .landscapeLeft:
            cameraOutput?.connection(with: .video)?.videoOrientation = .landscapeRight
        case .landscapeRight:
            cameraOutput?.connection(with: .video)?.videoOrientation = .landscapeLeft
        }
    
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }
    
}

extension AVView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        captureSession.stopRunning()
        if let error = error {
            debugPrint(error)
        } else {
            if let imageData = photo.fileDataRepresentation() {
                if let image = UIImage.init(data: imageData) {
                    delegate?.photo(image: image)
                }
            }
        }
    }
}
