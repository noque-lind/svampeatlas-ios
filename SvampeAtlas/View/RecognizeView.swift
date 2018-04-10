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
}


class RecognizeView: UIVisualEffectView {

    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var cameraControlsView: UIView!
    
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    
    
    
    private var originHeightConstant: CGFloat!
    var roundedMask = CAShapeLayer()
    var delegate: RecognizeViewDelegate? = nil
    
    
    @IBAction func captureButtonPressed(sender: UIButton) {
        delegate?.capturePhoto()
        
        
        UIView.animate(withDuration: 0.2, animations: {
            sender.alpha = 0
        }) { (_) in
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            sender.addSubview(activityView)
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.centerXAnchor.constraint(equalTo: sender.centerXAnchor).isActive = true
            activityView.centerYAnchor.constraint(equalTo: sender.centerYAnchor).isActive = true
            activityView.startAnimating()
        }
        
        
        
        
    }
    
    func showResults(results: [temptModel]) {
        resultsView.results = results
        expandView()
    }
    

    
    
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    private func setupView() {
        layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
    }
    
    
    private func collapseView() {
        
    }
    
    private func expandView() {
        originHeightConstant = heightConstraint.constant
        
        heightConstraint.constant = -500

        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            self.layer.shadowOpacity = 0.4
            self.layer.shadowRadius = 5.0
            self.superview?.layoutIfNeeded()
        }) { (finished) in
            self.resultsView.showResults()
        }
}
  
   
    
    
    
    
//    private func round() {
//        let radius = 25
//
//        let shapeLayer = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
//
//
//        // create new animation
//        let anim = CABasicAnimation(keyPath: "path")
//
//        // from value is the current mask path
//        anim.fromValue = self.roundedMask
//
//        // to value is the new path
//        anim.toValue = shapeLayer.cgPath
//
//        // duration of your animation
//        anim.duration = 5.0
//
//        // custom timing function to make it look smooth
//        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//
//        // add animation
//        roundedMask.add(anim, forKey: nil)
//
//        // update the path property on the mask layer, using a CATransaction to prevent an implicit animation
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        roundedMask.path = shapeLayer.cgPath
//        CATransaction.commit()
//
//    }
}
