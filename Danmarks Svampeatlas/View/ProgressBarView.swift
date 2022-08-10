//
//  ProgressBarView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 03/08/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ProgressBarViewDelegate: class {
    func completedLoading()
}

class ProgressBarView: UIView {
    
    private var loaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appThird()
        view.alpha = 0
        return view
    }()
    
    private var timer: Timer?
    private var counter: CGFloat = 0
    weak var delegate: ProgressBarViewDelegate?
    
    var progress: CGFloat = 0.0 {
        willSet {
            setProgress(progress: progress)
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(loaderView)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setProgress(progress: CGFloat) {
        if progress > 0.0 {
            loaderView.alpha = 1
            loaderView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width * progress, height: self.frame.height)
        } else if progress == 0.0 {
            loaderView.alpha = 0
            loaderView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width * progress, height: self.frame.height)
        }
    }
    
    func startLoading() {
        if timer != nil {
            reset()
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func handleTimer() {
        counter += 0.01
        
        setProgress(progress: counter / 1.5)
        
        if counter >= 1.5 {
            delegate?.completedLoading()
            reset()
        }
    }
    
    func reset() {
        timer?.invalidate()
        counter = 0
        setProgress(progress: 0.0)
    }
}
