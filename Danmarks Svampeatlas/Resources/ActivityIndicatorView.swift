//
//  ActivityIndicatorView.swift
//  ParseStarterProject-Swift
//
//  Created by Emil Møller Lind on 19/04/2017.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class Spinner: UIView {
    
    internal static weak var staticSpinnerView: UIView? {
        didSet {
            print("Static spinner set")
        }
    }
    
       init() {
            super.init(frame: CGRect.zero)
           setupView()
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
        private func setupView() {
            translatesAutoresizingMaskIntoConstraints = false
            alpha = 0
            backgroundColor = UIColor.clear
            let containerView = Spinner.createSpinnerView()
            addSubview(containerView)
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    
    func start() {
        alpha = 1
    }
    
    func stop() {
        alpha = 0
    }
    
    func addTo(view: UIView) {
        view.addSubview(self)
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
        
        }

//Static extension
extension Spinner {
    private static func createSpinnerView() -> UIView {
            let containerView: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                
                let activityIndicatorContainerView: UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.backgroundColor = UIColor.gray
                    view.clipsToBounds = true
                    view.layer.cornerRadius = 10
                    view.heightAnchor.constraint(equalToConstant: 80).isActive = true
                    view.widthAnchor.constraint(equalToConstant: 80).isActive = true
                    
                    let activityIndicatorView: UIActivityIndicatorView = {
                        let view = UIActivityIndicatorView(style: .whiteLarge)
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.startAnimating()
                        return view
                    }()
                    
                    view.addSubview(activityIndicatorView)
                    activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                    activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                    activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    return view
                }()
                
                view.addSubview(activityIndicatorContainerView)
                activityIndicatorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                activityIndicatorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                return view
            }()
            return containerView
    }
    
    
    public static func start(onView: UIView?) {
        guard let onView = onView else {return}
    
        if staticSpinnerView != nil {
            stop()
        }
        let spinner = Spinner.createSpinnerView()
        staticSpinnerView = spinner
        onView.addSubview(spinner)
        spinner.leadingAnchor.constraint(equalTo: onView.leadingAnchor).isActive = true
        spinner.trailingAnchor.constraint(equalTo: onView.trailingAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: onView.topAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: onView.bottomAnchor).isActive = true
    }
    
    public static func stop() {
        DispatchQueue.main.async {
            self.staticSpinnerView?.removeFromSuperview()
            staticSpinnerView = nil
        }
    }

}
    
    

