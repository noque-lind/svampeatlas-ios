//
//  ActionButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 28/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


class ActionButton: UIButton {
    
    struct State {
        let title: String
        let icon: UIImage
        let backgroundColor: UIColor
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    private var widthConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if let labelWidth = titleLabel?.intrinsicContentSize.width {
//            widthConstraint?.isActive = false
//            widthConstraint?.constant = labelWidth
//            widthConstraint?.isActive = true
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appGreen()
        layer.shadowOpacity = .shadowOpacity()
        layer.cornerRadius = .cornerRadius()
        layer.shadowOffset = .shadowOffset()
        titleLabel?.font = .appBold()
        titleLabel?.textColor = .appWhite()
//        widthConstraint = titleLabel?.widthAnchor.constraint(equalToConstant: 5)
        titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.imagePlacement = .trailing
            configuration.image = #imageLiteral(resourceName: "Glyphs_Checkmark")
            configuration.contentInsets = .init(top: 4, leading: 6, bottom: 4, trailing: 6)
            configuration.imagePadding = 8
      
            self.configuration = configuration
        } else {
            titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
            contentEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
            setImage(#imageLiteral(resourceName: "Glyphs_Checkmark"), for: [])
            semanticContentAttribute = UIApplication.shared
                .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        }
        
//        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
   
    func configure(text: String, icon: UIImage? = nil) {
        if #available(iOS 15.0, *) {
            configuration?.attributedTitle = AttributedString(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.appBold()]))
            if let icon = icon {
                configuration?.image = icon
            }
        } else {
            setTitle(text, for: [])
            setImage(icon, for: [])
        }
    }
    
    func configure(state: State) {
        if #available(iOS 15.0, *) {
            configuration?.attributedTitle = AttributedString(NSAttributedString(string: state.title, attributes: [NSAttributedString.Key.font: UIFont.appBold()]))
            configuration?.image = state.icon
        } else {
            setTitle(state.title, for: [])
            setImage(state.icon, for: [])
        }
        
        backgroundColor = state.backgroundColor
     layoutSubviews()
    }

}
