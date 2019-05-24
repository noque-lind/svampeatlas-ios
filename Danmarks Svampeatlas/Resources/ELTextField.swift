//
//  ELTextField.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ELTextViewDelegate: class {
    func shouldChangeHeight()
    func didUpdateTextEntry(title: String, _ text: String)
}


final class ELTextView: UIView, UITextViewDelegate {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowRadius = 2.0
        return view
    }()
    
    private lazy var titelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        return label
    }()
    
    lazy var textView: UITextView = {
       let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .justified
        view.isScrollEnabled = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    private var originalPlaceholder: String?
    private var originalBackgroundColor: UIColor?
    private var defaultHeight: CGFloat
    weak var delegate: ELTextViewDelegate?
    
    override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor, backgroundColor != UIColor.clear {
                backgroundView.backgroundColor = backgroundColor
                originalBackgroundColor = backgroundColor
                self.backgroundColor = nil
            }
        }
    }
    
    var shouldHandleKeyboard: Bool = true
    
    var textColor: UIColor = UIColor.white {
        didSet {
            tintColor = textColor
            textView.textColor = textColor
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize) {
        didSet {
            titelLabel.font = font
            textView.font = font
        }
    }
    
    var titleText: String? {
        didSet {
            titelLabel.text = titleText
        }
    }
    
    /**
     When ELTextField is given an placeholder, it automatically ensures it adjusts its layout.
     - important: Must not change the value after it has been set initially
     
     - returns: Nothing
     */
    var placeholder: String? {
        didSet {
            setPlaceholder()
        }
    }
    
    /**
     If no value is set, the placeholder color is defaults to the textColor property
     
     - returns: Nothing
     */
    var titleTextColor: UIColor? {
        didSet {
            titelLabel.textColor = titleTextColor
        }
    }
    
    var text: String? {
        set {
            textView.text = newValue
            setPlaceholder()
        } get {
            return textView.text
        }
    }
    
    
    init(defaultHeight: CGFloat = 120) {
        self.defaultHeight = defaultHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override var intrinsicContentSize: CGSize {
        if textView.intrinsicContentSize.height >= defaultHeight {
            return CGSize(width: frame.width, height: textView.intrinsicContentSize.height)
        } else {
            return CGSize(width: frame.width, height: defaultHeight)
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        addSubview(titelLabel)
        titelLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titelLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titelLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: 2).isActive = true
        
        addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        textView.topAnchor.constraint(equalTo: titelLabel.bottomAnchor, constant: -4).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didUpdateTextEntry(title: titelLabel.text ?? "", textView.text)
        
        if textView.intrinsicContentSize.height > textView.contentSize.height {
            ELKeyboardHelper.instance.reCalculate()
            delegate?.shouldChangeHeight()
        } else if textView.intrinsicContentSize.height < textView.contentSize.height && frame.height != defaultHeight {
            delegate?.shouldChangeHeight()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.attributedText = nil
            textView.font = font
            textView.textColor = textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if shouldHandleKeyboard {
            ELKeyboardHelper.instance.deRegisterObject()
        }
        
        if textView.text == nil || textView.text == "" {
            setPlaceholder()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if shouldHandleKeyboard {
            ELKeyboardHelper.instance.registerObject(view: self)
        }
        
         textView.inputAccessoryView = InputAccessoryView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50), withTitle: "Færdig", itemToResign: textView)
        return true
    }
    
    
    
    private func setPlaceholder() {
        guard let placeholder = placeholder, (text == nil || text == "") else {return}
        let attributedText = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : textColor.withAlphaComponent(0.4)])
        textView.attributedText = attributedText
    }
}


final class ELTextField: UITextField {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    private var originalPlaceholder: String?
    private var originalBackgroundColor: UIColor?
    private var showsError = false
    /**
     By altering this value, an imageView is automatically inserted on the leading edge of the textfield. The imageview.image value is then given this icon.
     - important: The icon must be 14x14 pixel
     
     - returns: Nothing
     */
    
    var icon: UIImage? {
        didSet {
            updateIcon()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if let backgroundColor = backgroundColor, backgroundColor != UIColor.clear {
                backgroundView.backgroundColor = backgroundColor
                originalBackgroundColor = backgroundColor
                self.backgroundColor = nil
            }
        }
    }
    
    
    /**
     When ELTextField is given an placeholder, it automatically ensures it adjusts its layout.
     - important: Must not change the value after it has been set initially
     
     - returns: Nothing
     */
    override var placeholder: String? {
        didSet {
            if !hasPlaceholder && placeholder != nil && placeholder != "" {
                originalPlaceholder = placeholder
                setupPlaceholder()
            }
            updatePlaceholder()
        }
    }
    
    /**
     If no value is set, the placeholder color is defaults to the textColor property
     
     - returns: Nothing
     */
    var placeholderColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    /**
     This value specifies the scale of which to calculate the placeholder font size.
     Defaults to 0.65
     
     - returns: Nothing
     */
    var placeholderFontScale: CGFloat = 0.65 {
        didSet {
            updatePlaceholder()
        }
    }
    
    override var textColor: UIColor? {
        didSet {
            tintColor = textColor
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
    
    override internal func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let widthInset: CGFloat = 5.0
        let xInset = (icon != nil ? leftViewRect(forBounds: bounds).maxX: 0) + widthInset
        let yInset = hasPlaceholder == true ? (placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant): 0.0
        return CGRect(x: xInset, y: yInset, width: bounds.width - xInset - widthInset, height: bounds.height - yInset)
    }
    
    override internal func editingRect(forBounds bounds: CGRect) -> CGRect {
        let widthInset: CGFloat = 5.0
        let xInset = (icon != nil ? leftViewRect(forBounds: bounds).maxX: 0) + widthInset
        let yInset = hasPlaceholder == true ? (((placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant) + (((bounds.height - placeholderLabel.frame.maxY - backgroundViewTopAnchor.constant) / 2) - font!.pointSize / 2)) - 2): 0.0
        return CGRect(x: xInset, y: yInset, width: bounds.width - xInset, height: bounds.height)
    }
    
    override internal func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let yInset = hasPlaceholder == true ? (placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant): 0.0
        return CGRect(x: 5, y: yInset + ((bounds.height - yInset) / 2) - iconImageView.frame.height / 2, width: iconImageView.frame.width, height: iconImageView.frame.height)
    }
    
    override internal func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let yInset = hasPlaceholder == true ? (placeholderLabel.frame.maxY + backgroundViewTopAnchor.constant): 0.0
        return CGRect(x: bounds.width - 10 - 3, y: yInset, width: 3, height: 3)
    }
    
    override internal func textRect(forBounds bounds: CGRect) -> CGRect {
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
    
    private func setupView() {
        contentVerticalAlignment = .center
        insertSubview(backgroundView, at: 0)
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundViewHeightAnchor.isActive = true
        addTarget(self, action: #selector(editingChanged), for: UIControl.Event.editingChanged)
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
        guard let placeholder = placeholder, let font = font, let textColor = textColor else {return}
        
       let attributedString = NSMutableAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: font.fontName, size: font.pointSize * 0.8) ?? font, NSAttributedString.Key.foregroundColor: placeholderColor ?? textColor])
        attributedPlaceholder = attributedString
        
        if hasPlaceholder {
        placeholderLabel.attributedText = attributedString
        }
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
    
    @objc private func editingChanged() {
        if showsError {
            backgroundView.backgroundColor = originalBackgroundColor
            placeholder = originalPlaceholder
        }
    }
}

extension ELTextField {
    func showError(message: String?) {
        showsError = true
        backgroundView.backgroundColor = #colorLiteral(red: 0.9667708278, green: 0.3270001709, blue: 0.3416224122, alpha: 1)
        shake(duration: 0.6)
    
        if hasPlaceholder {
            placeholder = message
            
            if isExpanded {
                placeholder = nil
            }
        } else {
            hasPlaceholder = true
            placeholder = message
            hasPlaceholder = false
        }
    }
}

fileprivate extension UIView {
    func shake(duration: CFTimeInterval) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = duration
        animation.values = [-10, 10, -10, 10, -5, 5, -2, 2, 0]
        layer.add(animation, forKey: "shake")
    }
    
    func animateBorder(duration: CFTimeInterval) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = 1
        borderWidth.duration = duration
        self.layer.add(borderWidth, forKey: "Width")
        self.layer.borderWidth = 1.0
    }
    
}
