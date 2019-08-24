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

class ELNavigationBar: UIView {
    
    private var backgroundView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var titleTextView: UILabel = {
       let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.alpha = 0.0
        view.font = UIFont.appTitle()
        view.textColor = UIColor.appWhite()
        return view
    }()
    
    private var _maxHeight: CGFloat = 0 {
        didSet {
            heightConstraint.isActive = false
            heightConstraint.constant = maxHeight
            heightConstraint.isActive = true
        }
    }
    
    public var maxHeight: CGFloat {
        get {
            if _maxHeight == 0 {
                return minHeight
            } else {
                if !ignoreSafeArea {
                    return _maxHeight + safeAreaInsets.top
                } else {
                    return _maxHeight
                }
                
            }
        }
    }
    
    private var ignoreSafeArea: Bool = false
    
    private var isCollapsed = true
    
    var minHeight: CGFloat = 0 {
        didSet {
            if (_maxHeight == 0) {
                heightConstraint.isActive = false
                heightConstraint.constant = minHeight
                heightConstraint.isActive = true
            }
        }
    }
    
    private var heightConstraint = NSLayoutConstraint()
    
    private var contentView: UIView?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.shadowOffset = CGSize(width: 0.0, height: 1.5)
        layer.shadowRadius = 3.0
        backgroundColor = UIColor.clear
        
        heightConstraint = heightAnchor.constraint(equalToConstant: minHeight)
        heightConstraint.isActive = true
    }
    
    func setContentView(view: UIView, ignoreSafeAreaLayoutGuide: Bool, maxHeight: CGFloat, topPadding: CGFloat = 0.0, bottomPadding: CGFloat = 0.0) {
        self.ignoreSafeArea = ignoreSafeAreaLayoutGuide
        self._maxHeight = maxHeight + topPadding + bottomPadding
        isCollapsed = true
        contentView = view
        
        insertSubview(view, at: 0)
        view.topAnchor.constraint(equalTo: ignoreSafeAreaLayoutGuide ? topAnchor: safeAreaLayoutGuide.topAnchor, constant: topPadding).isActive = true
        view.leadingAnchor.constraint(equalTo: ignoreSafeAreaLayoutGuide ? leadingAnchor: safeAreaLayoutGuide.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: ignoreSafeAreaLayoutGuide ? trailingAnchor: safeAreaLayoutGuide.trailingAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: maxHeight).isActive = true
    }
    
    func setTitle(title: String?) {
        guard let title = title else {return}
        
        addSubview(titleTextView)

        titleTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        titleTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        titleTextView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        titleTextView.text = title
    }
    
    func setPercentExpanded(_ percent: CGFloat) {
        if (maxHeight == minHeight) {
            backgroundColor = UIColor.appPrimaryColour()
            if percent <= 0 {
                isCollapsed = false
                onCollapsed()
            } else {
                onExpanding()
            }
        } else {
            let adjustedPercent = ((maxHeight * (1 - percent)) - ((maxHeight - minHeight) * (1 - percent))) / (maxHeight - minHeight)
            contentView?.alpha = percent - adjustedPercent
            backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(1 - percent + adjustedPercent)
            
            
            if percent < 0.0 {
                onCollapsed()
            } else {
                onExpanding()
            }
            
            let constraintValue =  max(minHeight, maxHeight * max(0.0, percent))
            
            if percent > 1 {
                let transform = CGAffineTransform(scaleX: percent, y: percent)
                contentView?.transform = transform
            } else if constraintValue < maxHeight {
                contentView?.transform = CGAffineTransform(translationX: 0.0, y: -(40 - 40 * percent))
            } else {
                contentView?.transform = CGAffineTransform.identity
            }
            
            heightConstraint.constant = constraintValue
            
        }
      
    }
    
    func onCollapsed() {
        guard !isCollapsed else {return}
        isCollapsed = true
        clipsToBounds = false
        layer.animate().shadowOpacity(shadowOpacity: 0.4).start()
        
        if titleTextView.alpha == 0 {
            titleTextView.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
            UIView.animate(withDuration: 0.2) {
                self.titleTextView.transform = CGAffineTransform.identity
                self.titleTextView.alpha = 1
            }
        }
    }
    
    func onExpanding() {
        guard isCollapsed else {return}
        isCollapsed = false
        layer.animate().shadowOpacity(shadowOpacity: 0.0).start()
        clipsToBounds = true
        if titleTextView.alpha == 1 {
            UIView.animate(withDuration: 0.1) {
                self.titleTextView.alpha = 0
            }
        }

    }
}

