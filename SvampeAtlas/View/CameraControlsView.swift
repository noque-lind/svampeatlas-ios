//
//  CameraControlsVieew.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol CameraControlsViewDelegate: class {
    func capturePhoto()
}

class CameraControlsView: UIView {

    private lazy var captureButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CaptureBtn"), for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = UIColor.appWhite()
        view.alpha = 0
        return view
    }()
    
    weak var delegate: CameraControlsViewDelegate? = nil
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
       backgroundColor = UIColor.clear
        
        addSubview(captureButton)
        captureButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        captureButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    @objc func captureButtonPressed() {
        delegate?.capturePhoto()
        
        self.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicatorView.startAnimating()
        
        UIView.animate(withDuration: 0.2) {
            self.captureButton.alpha = 0
            self.activityIndicatorView.alpha = 1
        }
    }

    func removeActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.alpha = 0
    }
    
    func reset() {
        captureButton.alpha = 1
    }
}
    
  
