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
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        

        view.addSubview(contentStackView)
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        return view
    }()
    
    var navigationBarOffset: CGFloat? {
        didSet {
            contentViewTopAnchor.isActive = false
            contentViewTopAnchor.constant = navigationBarOffset != nil ? navigationBarOffset! + 4: 4
            contentViewTopAnchor.isActive = true
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
        if alpha >= 1.0 {
            showContent()
        } else {
            hideContent()
        }
    }
    
    func configureContent(stackView: UIStackView, alignment: UIStackViewAlignment) {
        stackView.axis = .horizontal
        contentStackView.alignment = alignment
        contentStackView.addArrangedSubview(stackView)
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
