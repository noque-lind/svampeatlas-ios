//
//  CaptureButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 26/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CaptureButton: UIButton {
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = UIColor.appWhite()
        view.alpha = 0
        return view
    }()
    
    var pressed: (() -> ())?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        setImage(#imageLiteral(resourceName: "Icons_Utils_CaptureButton"), for: [])
        addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
    }
    
    @objc private func captureButtonPressed(sender: UIButton) {
        pressed?()
    }
    
    func showSpinner(_ show: Bool) {
        switch show {
        case false:
            activityIndicatorView.removeFromSuperview()
            activityIndicatorView.alpha = 0
        case true:
            addSubview(activityIndicatorView)
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            activityIndicatorView.startAnimating()
            
            UIView.animate(withDuration: 0.2) {
            self.alpha = 0
            self.activityIndicatorView.alpha = 1
                }
            }
    }
}
