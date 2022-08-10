//
//  ImageCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

extension ImageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === pinchGesture && otherGestureRecognizer === panGesture {
            return true
        } else {
            return false
        }
    }
//
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isZooming && gestureRecognizer == panGesture {
            return true
        } else if gestureRecognizer == pinchGesture {
            return true
        } else {
            return false
        }
    }
}

class ImageCell: UICollectionViewCell {
    
    private lazy var imageView: DownloadableImageView = {
       let imageView = DownloadableImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(self.pinchGesture)
        imageView.addGestureRecognizer(self.panGesture)
        return imageView
    }()
    
    lazy var pinchGesture: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch.delegate = self
        return pinch
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        return pan
    }()
    
    var isZooming = false
    var originalImageCenter: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
   lazy var gradient: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0.8)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        return gradient
    }()
    
    lazy var authorGradientView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.addSublayer(gradient)
        return view
    }()
    
    func configureCell(contentMode: UIView.ContentMode, url: String, photoAuthor: String?) {
        imageView.contentMode = contentMode
        imageView.downloadImage(size: .full, urlString: url, fade: true)
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
   @objc func pan(sender: UIPanGestureRecognizer) {
    if isZooming {
        let currentScale = 100 / ((imageView.frame.size.width / imageView.bounds.size.width) * 100)
        let translation = sender.translation(in: self)
        imageView.transform = imageView.transform.translatedBy(x: currentScale * translation.x, y: currentScale * translation.y)
        sender.setTranslation(CGPoint.zero, in: imageView.superview)
    }
    }
    
@objc func pinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            let newScale = currentScale*sender.scale
            
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            
            guard let view = sender.view else {return}
            
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            var newScale = currentScale*sender.scale
            
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                imageView.transform = transform
                sender.scale = 1
            } else {
                view.transform = transform
                sender.scale = 1
            }
            
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.isZooming = false
            })
        }
        
    }
}
