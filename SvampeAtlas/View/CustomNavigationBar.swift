//
//  CustomNavigationBar.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CustomNavigationBar: UIView {

    private var contentViewTopAnchor = NSLayoutConstraint()
    
    private lazy var backgroundView: UIView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffect.Style.light))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        return view
    }()
    
    var navigationBarOffset: CGFloat? {
        didSet {
            contentViewTopAnchor.isActive = false
            contentViewTopAnchor.constant = navigationBarOffset != nil ? navigationBarOffset! + 4: 4
            contentViewTopAnchor.isActive = true
        }
    }
    
    var heightConstraint: NSLayoutConstraint? {
        willSet {
            heightConstraint?.isActive = false
        } didSet {
            heightConstraint?.isActive = true
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.alpha = 0
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 30)
        
        addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        contentViewTopAnchor = contentView.topAnchor.constraint(equalTo: topAnchor, constant: navigationBarOffset != nil ? navigationBarOffset! + 4: 0 + 4)
        contentViewTopAnchor.isActive = true
    }
    
    func changeAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
        if alpha >= 1.2 {
            showContent()
        } else {
            hideContent()
        }
    }
    
    func configureTitle(_ string: String?) {
        guard let string = string else {return}
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appHeader()
            label.textColor = UIColor.appWhite()
            label.textAlignment = .center
            label.text = string
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    

    private func showContent() {
        if contentView.alpha == 0 {
            contentView.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
            UIView.animate(withDuration: 0.2) {
                self.contentView.transform = CGAffineTransform.identity
                self.contentView.alpha = 1
            }
        }
    }
    
    private func hideContent() {
        if contentView.alpha == 1 {
            UIView.animate(withDuration: 0.2) {
                self.contentView.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
                self.contentView.alpha = 0
            }
        }

    }
}
