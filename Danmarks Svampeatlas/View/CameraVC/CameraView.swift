//
//  RecognizeView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

struct temptModel {
    var identifier: String
    var confidence: CGFloat
}

protocol CameraViewDelegate: CameraControlsViewDelegate, ResultsViewDelegate {}

class CameraView: UIVisualEffectView {
    
    private var resultsView: ResultsView = {
        let view = ResultsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cameraControlsView: CameraControlsView = {
        let hasNoPhotoButton: Bool
        switch self.cameraVCUsage {
        case .mlPredict, .imageCapture:
            hasNoPhotoButton = false
        case .newObservationRecord, .tempNewObservationRecord:
            hasNoPhotoButton = true
        }
        
        
        let view = CameraControlsView(hasNoPhotoButton: hasNoPhotoButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public private(set) var isExpanded = false
    var topConstraint: NSLayoutConstraint!
    var orientation: CameraVC.CameraRotation = .portrait {
        didSet {
            cameraControlsView.orientation = self.orientation
        }
    }
    
    private var cameraVCUsage: CameraVC.CameraVCUsage
    weak var delegate: CameraViewDelegate? = nil {
        didSet {
            cameraControlsView.delegate = delegate
            resultsView.delegate = delegate
        }
    }
    
    
    init(cameraVCUsage: CameraVC.CameraVCUsage) {
        self.cameraVCUsage = cameraVCUsage
        super.init(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        contentView.addSubview(cameraControlsView)
        cameraControlsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        cameraControlsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        cameraControlsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cameraControlsView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        contentView.addSubview(resultsView)
        resultsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        resultsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        resultsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        resultsView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
    }
    
    
    private func expandView() {
        isExpanded = true
        
        topConstraint.constant = (UIScreen.main.bounds.height / 3) * 2
        
        cameraControlsView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }) { (finished) in
            self.resultsView.showResults()
        }
    }
    
    func showResults(results: [temptModel]) {
        resultsView.results = results
        expandView()
    }
    
    func reset() {
        topConstraint.constant = -70
        isExpanded = false
        resultsView.reset()
        cameraControlsView.reset()
        cameraControlsView.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }) { (finished) in
        }
    }
}
