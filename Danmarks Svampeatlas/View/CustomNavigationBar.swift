//
//  CustomNavigationBar.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AppNavigationBar: UIView {
    
    enum NavigationBarType {
        case transparent
        case solid
    }
    
    enum ItemType {
        case menuButton
        case exitButton
    }
    
    private lazy var transparentView: UIView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect.init(style: UIBlurEffect.Style.light))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 1
        
        view.addSubview(leftMenuItem)
        leftMenuItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        leftMenuItem.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    private lazy var leftMenuItem: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return button
    }()
    
    
    private let navigationBarType: NavigationBarType
    
    

    init(navigationBarType: NavigationBarType) {
        self.navigationBarType = navigationBarType
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        self.alpha = 1
        
        
        switch navigationBarType {
        case .solid:
            backgroundColor = UIColor.appPrimaryColour()
        case .transparent:
            addSubview(transparentView)
            transparentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            transparentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            transparentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            transparentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
    
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    }
    

    
    func setLeftItem(itemType: ItemType) {
        switch itemType {
        case .menuButton:
            leftMenuItem.setImage(#imageLiteral(resourceName: "MenuButton"), for: [])
        case .exitButton:
            leftMenuItem.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        }
    }
    
    
}

class CustomNavigationBar: UIView {

    private var contentViewTopAnchor = NSLayoutConstraint()
    private var contentViewLeadingAnchor: NSLayoutConstraint? {
        willSet {
            contentViewLeadingAnchor?.isActive = false
        } didSet {
            contentViewLeadingAnchor?.isActive = true
        }
    }
    
    private var contentViewTrailingAnchor: NSLayoutConstraint? {
        willSet {
            contentViewTrailingAnchor?.isActive = false
        } didSet {
            contentViewTrailingAnchor?.isActive = true
        }
    }
    
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
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 300)
        self.heightConstraint?.isActive = true
        
        addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(contentView)
        contentViewLeadingAnchor = contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30)
        contentViewTrailingAnchor = contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4).isActive = true
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
            label.font = UIFont.appTitle()
            label.textColor = UIColor.appWhite()
            label.textAlignment = .center
            label.text = string
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
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
