//
//  ActivityIndicatorView.swift
//  ParseStarterProject-Swift
//
//  Created by Emil Møller Lind on 19/04/2017.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit


extension UIView {
    // NOTE DID NOT WRITE; DO NOT UNDERSTAND
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    
    func controlActivityIndicator(wantRunning: Bool) {
        
    let overlayView = UIView()
        overlayView.tag = 51
    
    let loadingView = UIView()
        
        loadingView.tag = 52
      
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 40, height: 40))
        activityIndicator.tag = 53
        
        if wantRunning == true {
        
                // OverlayView
        overlayView.backgroundColor = hexStringToUIColor(hex: "0xffffff")
        overlayView.alpha = 0.5
        
        
                // The loading view
        
        loadingView.backgroundColor = hexStringToUIColor(hex: "0x444444")
        loadingView.alpha = 0.7
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
                // ActivitySetup
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        self.addSubview(overlayView)
        self.addSubview(loadingView)
        self.addSubview(activityIndicator)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            overlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            overlayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            loadingView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            loadingView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            activityIndicator.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor).isActive = true
            activityIndicator.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor).isActive = true
            activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor).isActive = true
            activityIndicator.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor).isActive = true
            
            
        } else {
            activityIndicator.stopAnimating()
            removeSubView(withTag: 51)
            removeSubView(withTag: 52)
            removeSubView(withTag: 53)
        }
        
    }
    
    func removeSubView(withTag tag: Int) {
        if let viewWithTag = self.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
}
