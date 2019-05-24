//
//  ELMessageView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/02/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import AVFoundation
import UIKit

public enum QueuePosition: Int {
    case back
    case front
}

final class Queue: NSObject {
    
    enum QueuePosition {
        case back
        case front
    }
    
    
    static let instance = Queue()
    private override init() {}
    
    private var notificationViews = [ELNotificationView]() {
        didSet {
            if oldValue.count == 0 {
                executeNext()
            }
        }
    }
    
    var numberOfItems: Int {
        return notificationViews.count
    }
    
    fileprivate func add(_ notificationView: ELNotificationView, queuePosition: QueuePosition) {
        switch queuePosition {
        case .back:
            notificationViews.append(notificationView)
        case .front:
            if let firstNotificationView = notificationViews.first {
                firstNotificationView.suspend {
                    self.notificationViews.insert(notificationView, at: 0)
                    self.executeNext()
                }
            } else {
                notificationViews.insert(notificationView, at: 0)
            }
        }
    }
    
    private func executeNext() {
        guard let notificationView = notificationViews.first else {return}
        notificationView.show()
    }
    
    fileprivate func remove(_ notificationView: ELNotificationView) {
        guard let index = notificationViews.firstIndex(of: notificationView) else {return}
        notificationViews.remove(at: index)
        executeNext()
    }
}



class ELNotificationView: UIView {
    
    enum AnimationType {
        case fade
        case fromRight
        case fromLeft
        case fromTop
        case fromBottom
        case zoom
    }
    
    enum Location {
        case top
        case bottom
        case center
    }
    
    
    enum Style {
        
        ///Should be used to express that a fatal error has occured. The notification does not automatically dissapear when this style is selected.
        case error
        
        ///Should be used to express that a user initiated action was successfull. The notification dissapears by default after 5 seconds.
        case success
        
        ///Should be used to express that the user should pay attention to something that may, or may not, require user interaction.
        case warning
        
        ///Use this option to create your own style.
        /// - Parameter image: The image should be 30x30 pixels.
        case Custom(color: UIColor, image: UIImage)
    }
    
    struct Attributes {
        ///Defines whether the notification takes up the whole screen width. If this is false, cornerRadius does not get applied.
        var fillsScreen: Bool
        var cornerRadius: CGFloat
        var borderWidth: CGFloat
        var font: UIFont
        var textColor: UIColor
        
        init(fillsScreen: Bool = false, cornerRadius: CGFloat = 5, borderWidth: CGFloat = 0.5, font: UIFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold), textColor: UIColor = UIColor.darkGray) {
            self.fillsScreen = fillsScreen
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.font = font
            self.textColor = textColor
        }
    }
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.font = attributes.font
        textStackView.insertArrangedSubview(label, at: 0)
        return label
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.font = attributes.font.withSize(attributes.font.pointSize * 0.8)
        textStackView.addArrangedSubview(label)
        return label
    }()
    
    private var textStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var attributes: Attributes
    private var animationType: AnimationType = .fromBottom
    private var location: Location = .bottom
    private var duration: TimeInterval = 5.0
    private var queue = Queue.instance
    private var parentViewController: UIViewController?
    private var isDisplaying = false
    var onTap: (() -> ())? {
        didSet {
            if onTap != nil {
                let disclosureContainerView: UIView = {
                   let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.backgroundColor = UIColor.clear
                    view.widthAnchor.constraint(equalToConstant: 14).isActive = true
                    
                    let disclosureImageView: UIImageView = {
                       let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "DisclosureButton").withRenderingMode(.alwaysTemplate)
                        view.contentMode = .scaleAspectFit
                        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
                        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
                        view.tintColor = UIColor.darkGray
                        return view
                    }()
                    
                    view.addSubview(disclosureImageView)
                    disclosureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                    disclosureImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                    return view
                }()
                
                stackView.addArrangedSubview(disclosureContainerView)
            }
        }
    }
    

    deinit {
        print("ELMESSAGEVIEW Deinited")
    }
    
    ///Use this initializer when you just want to use default attribute values.
    init(style: Style, primaryText: String? = nil, secondaryText: String? = nil, location: Location = Location.bottom) {
        self.location = location
        self.attributes = Attributes()
        super.init(frame: CGRect.zero)
        
        if let primaryText = primaryText {
            mainLabel.text = primaryText
        }
        
        if let secondaryText = secondaryText {
            secondaryLabel.text = secondaryText
        }
        
        setupView(style: style, styles: attributes)
    }
    
    ///Use this initializer when you want to specify specific attributes for the notification view.
    init(style: Style, attributes: Attributes, primaryText: String? = nil, secondaryText: String? = nil, location: Location = Location.bottom) {
        self.location = location
        self.attributes = attributes
        super.init(frame: CGRect.zero)
        
        if let primaryText = primaryText {
            mainLabel.text = primaryText
        }
        
        if let secondaryText = secondaryText {
            secondaryLabel.text = secondaryText
        }
    
        setupView(style: style, styles: attributes)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    ///Use this method if you want to configure the content of the notification view, after it has been initialized.
    func configure(primaryText: String? = nil, secondaryText: String? = nil) {
       
        if let primaryText = primaryText {
            mainLabel.text = primaryText
        }
        
        if let secondaryText = secondaryText {
            secondaryLabel.text = secondaryText
        }
    }
    

    
    ///Use this method when the notification view has been fully configured and it should be shown.
    /// - Parameter animationType: The type of animation that should be used when showing the notification.
    /// - Parameter queuePosition: Specify whether the notification should be placed in front, or in back of the notification queue. If put in front, the currently showing notification, if any, will be suspended and this notification will be shown immediately. The suspended notification will show again after this one has been dismissed.
    /// - Parameter onViewController: Specify which ViewController you want to show the notification on. This is especially handy in situations where two ViewControllers are currently in the window. If none is specified, the notification will be shown on the main application window.
    
    func show(animationType: AnimationType, queuePosition: Queue.QueuePosition = .back, onViewController parentViewController: UIViewController? = nil) {
        self.parentViewController = parentViewController
        self.animationType = animationType
        queue.add(self, queuePosition: queuePosition)
    }
    
    
    private func setupView(style: Style, styles: Attributes) {
        var color: UIColor
        var image = #imageLiteral(resourceName: "Test")
        
        switch style {
        case .success:
            color = #colorLiteral(red: 0.4235294118, green: 0.737254902, blue: 0.2235294118, alpha: 1)
        case .warning:
            color = #colorLiteral(red: 0.9631099105, green: 0.6938561201, blue: 0.2166337967, alpha: 1)
            
        case .error:
            color = #colorLiteral(red: 0.8980392157, green: 0.4784313725, blue: 0.4431372549, alpha: 1)
            
        case .Custom(color: let customColor, image: let customImage):
            color = customColor
            image = customImage
        }
        
        alpha = 0
        backgroundColor = UIColor.clear
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        let containerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.white
            view.layer.borderColor = color.cgColor
            view.clipsToBounds = true
            view.layer.borderWidth = styles.borderWidth
            view.layer.cornerRadius = styles.cornerRadius
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerTapped(gesture:))))
            
            let imageViewContainerView: UIView = {
               let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.layer.borderColor = color.withAlphaComponent(0.5).cgColor
                view.backgroundColor = color.withAlphaComponent(0.3)
                view.widthAnchor.constraint(equalToConstant: 60).isActive = true
                view.layer.borderWidth = styles.borderWidth
                
                let imageView: UIImageView = {
                   let view = UIImageView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    view.heightAnchor.constraint(equalToConstant: 30).isActive = true
                    view.tintColor = color
                    view.contentMode = .scaleAspectFit
                    view.image = image.withRenderingMode(.alwaysTemplate)
                    return view
                }()
                
                view.addSubview(imageView)
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                return view
            }()
            
            view.addSubview(imageViewContainerView)
            imageViewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imageViewContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageViewContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            
            view.addSubview(stackView)
            stackView.leadingAnchor.constraint(equalTo: imageViewContainerView.trailingAnchor, constant: 4).isActive = true
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4).isActive = true
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true
            
            stackView.addArrangedSubview(textStackView)
            
            return view
        }()
        
        addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc private func tapGestureRecognizerTapped(gesture: UITapGestureRecognizer) {
        self.dismiss(animationType: .fade) {
            self.queue.remove(self)
            self.removeFromSuperview()
            self.onTap?()
        }
    }
    
    
    private func addTo(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
    
        switch location {
        case .bottom:
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        case .top:
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            heightAnchor.constraint(equalToConstant: 60).isActive = true
        case .center:
            centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64).isActive = true
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64).isActive = true
            heightAnchor.constraint(equalToConstant: 120).isActive = true
        }
        
    }
    
    

    fileprivate func show() {
        if let parentViewController = parentViewController {
            addTo(view: parentViewController.view)
        } else {
            guard let window = UIApplication.shared.delegate!.window! else {return}
            addTo(view: window)
        }
        
        isDisplaying = true
        
        AudioServicesPlaySystemSound(SystemSoundID(1521))
        
        switch animationType {
        case .fromBottom:
            self.transform = CGAffineTransform(translationX: 0.0, y: 50)
        case .fromLeft:
            self.transform = CGAffineTransform(translationX: -50.0, y: 0)
        case .fromTop:
            self.transform = CGAffineTransform(translationX: 0.0, y: -50)
        case .fromRight:
            self.transform = CGAffineTransform(translationX: 50.0, y: 0.0)
        default: break
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration, execute: { [weak self] in
                guard let self = self else {return}
                self.dismiss(animationType: self.animationType, completion: {
                    self.queue.remove(self)
                    self.removeFromSuperview()
                })
            })
        }
    }
    
    ///This function suspends the notification view. This means that it dismisses using the .zoom animation type, and then resets, and prepares itself for presentation again.
    fileprivate func suspend(completion: @escaping () -> ()) {
        guard isDisplaying else {completion(); return}
        dismiss(animationType: .zoom, completion: {
            self.isDisplaying = false
            completion()
        })
    }
    
    
    private func dismiss(animationType: AnimationType, completion: @escaping () -> ()) {
        guard isDisplaying else {return}
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.alpha = 0
            
            switch animationType {
            case .fromBottom:
                self.transform = CGAffineTransform(translationX: 0.0, y: 50)
            case .fromLeft:
                self.transform = CGAffineTransform(translationX: 50.0, y: 0)
            case .fromTop:
                self.transform = CGAffineTransform(translationX: 0.0, y: -50)
            case .fromRight:
                self.transform = CGAffineTransform(translationX: -50.0, y: 0.0)
            case .fade: break
            case .zoom:
                self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }) { (_) in
            completion()
        }
    }
}

