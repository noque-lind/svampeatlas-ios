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

protocol RecognizeViewDelegate: NSObjectProtocol {
    func capturePhoto()
    func pushVC(vc: UIViewController)
    func presentVC(vc: UIViewController)
    func resetSession()
    func photoFromPhotoLibraryWasChoosen(image: UIImage)
}


class RecognizeView: UIVisualEffectView {

    private lazy var resultsView: ResultsView = {
       let view = ResultsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var cameraControlsView: CameraControlsView = {
        let view = CameraControlsView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var topConstraint: NSLayoutConstraint!
    var delegate: RecognizeViewDelegate? = nil
    public private(set) var isExpanded = false
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        contentView.addSubview(cameraControlsView)
        cameraControlsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        cameraControlsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        cameraControlsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cameraControlsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(resultsView)
        resultsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        resultsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        resultsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        resultsView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func expandView() {
        topConstraint.constant = -500
        isExpanded = true
        cameraControlsView.removeActivityIndicator()
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

extension RecognizeView: CameraControlsViewDelegate, ResultsViewDelegate {
    func photoFromPhotoLibraryWasChoosen(image: UIImage) {
        delegate?.photoFromPhotoLibraryWasChoosen(image: image)
    }
    
    func presentVC(_ vc: UIViewController) {
        delegate?.presentVC(vc: vc)
    }
    
    func capturePhoto() {
        delegate?.capturePhoto()
    }
    
    func didSelectSpecies(species: temptModel) {
        delegate?.pushVC(vc: NewObservationVC())
    }
    
    func retry() {
        delegate?.resetSession()
    }
    
}
