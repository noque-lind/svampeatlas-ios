//
//  ELTextField.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

final class ELTextField: UITextField {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appSecondaryColour()
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowRadius = 4.0
        return view
    }()
    
    private lazy var backgroundViewHeightAnchor: NSLayoutConstraint = {
        var constraint = NSLayoutConstraint()
        constraint = backgroundView.heightAnchor.constraint(equalToConstant: 1)
        return constraint
    }()
    
    private lazy var backgroundViewTopAnchor: NSLayoutConstraint = {
        var constraint = NSLayoutConstraint()
        constraint = backgroundView.topAnchor.constraint(equalTo: topAnchor)
        return constraint
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    private var isExpanded: Bool = false
    private var hasPlaceholder: Bool = false
    
    var icon: UIImage? {
        didSet {
            updateIcon()
        }
    }
    
    override var placeholder: String? {
        didSet {
            if !hasPlaceholder && placeholder != nil && placeholder != "" {
                setupPlaceholder()
            }
            updatePlaceholder()
        }
    }
    
    var placeholderColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    var placeholderFontScale: CGFloat = 0.65 {
        didSet {
            updatePlaceholder()
        }
    }
    
    override var textColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override var text: String? {
        didSet {
            guard text != nil, text != "" else {return}
            setState(hasText: true)
        }
    }
    
    override var font: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let widthInset: CGFloat = 5.0
        let xInset = (icon != nil ? leftViewRect(forBounds: bounds).maxX: 0) + widthInset
        let yInset = hasPlaceholder == true ? (placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant): 0.0
        return CGRect(x: xInset, y: yInset, width: bounds.width - xInset - widthInset, height: bounds.height - yInset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let widthInset: CGFloat = 5.0
        let xInset = (icon != nil ? leftViewRect(forBounds: bounds).maxX: 0) + widthInset
        let yInset = hasPlaceholder == true ? (((placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant) + (((bounds.height - placeholderLabel.frame.maxY - backgroundViewTopAnchor.constant) / 2) - font!.pointSize / 2)) - 2): 0.0
        return CGRect(x: xInset, y: yInset, width: bounds.width - xInset, height: bounds.height)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let yInset = hasPlaceholder == true ? (placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant): 0.0
        return CGRect(x: 5, y: yInset + ((bounds.height - yInset) / 2) - iconImageView.frame.height / 2, width: iconImageView.frame.width, height: iconImageView.frame.height)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let widthInset: CGFloat = 5.0
        let xInset = (icon != nil ? leftViewRect(forBounds: bounds).maxX: 0) + widthInset
        let yInset = hasPlaceholder == true ? (((placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant) + (((bounds.height - placeholderLabel.frame.maxY - backgroundViewTopAnchor.constant) / 2) - font!.pointSize / 2)) - 2): 0.0
        return CGRect(x: xInset, y: yInset, width: bounds.width - xInset, height: bounds.height)
    }
    
    override func becomeFirstResponder() -> Bool {
        placeholder = nil
        
        expand() { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.setState(hasText: true)
            })
        }
        
        super.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        let animationBlock = {
            if self.hasPlaceholder {
                self.setState(hasText: self.text != "")
            }
        }
        
        collapse(animationBlock: animationBlock)
        super.resignFirstResponder()
        return true
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setState(hasText: Bool) {
        if hasText {
            leftView?.alpha = 1
            if hasPlaceholder {
                placeholderLabel.alpha = 1
            }
        } else {
            leftView?.alpha = 0.7
            if hasPlaceholder {
                placeholder = placeholderLabel.text
                placeholderLabel.alpha = 0
            }
        }
    }
    
    private func setupView() {
        contentVerticalAlignment = .center
        insertSubview(backgroundView, at: 0)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundViewHeightAnchor.isActive = true
    }
    
    private func expand(completion: @escaping (Bool) -> ()) {
        guard isExpanded == false else {return}
        isExpanded = true
        backgroundViewHeightAnchor.isActive = false
        backgroundViewTopAnchor.isActive = true
        
        UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    private func collapse(animationBlock: @escaping () -> ()?) {
        isExpanded = false
        backgroundViewTopAnchor.isActive = false
        backgroundViewHeightAnchor.isActive = true
        
        UIView.animate(withDuration: 0.15, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseOut, animations: {
            animationBlock()
            self.layoutIfNeeded()
        }, completion: nil)
    }

    private func updatePlaceholder() {
        guard let placeholder = placeholder, let font = font, let textColor = textColor, hasPlaceholder == true else {return}
        
        let attributedString = NSMutableAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: font.fontName, size: font.pointSize * 0.8) ?? font, NSAttributedString.Key.foregroundColor: placeholderColor ?? textColor])
        attributedPlaceholder = attributedString
        placeholderLabel.attributedText = attributedString
    }
    
    private func updateIcon() {
        guard let icon = icon else {return}
        leftViewMode = .always
        iconImageView.image = icon
        leftView = iconImageView
        leftView?.alpha = 0.8
    }
    
    private func setupPlaceholder() {
        contentVerticalAlignment = .fill
        addSubview(placeholderLabel)
        placeholderLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundViewTopAnchor = backgroundView.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 5)
        hasPlaceholder = true
    }
}
