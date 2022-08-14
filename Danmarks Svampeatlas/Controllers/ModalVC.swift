//
//  TermsController.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 12/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ModalVC: UIViewController {
    
    enum Terms {
        case mlPredict
        case localityHelper
        case cameraHelper
        case deleteImageTip
        case whatsNew
    }
    
    private let header: SectionHeaderView = {
        let view = SectionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textView: UILabel = {
        let view = UILabel()
        view.font = UIFont.appPrimary()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor.appWhite()
        view.backgroundColor = UIColor.clear
        view.numberOfLines = 0
        return view
    }()
    
    private let acceptButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(NSLocalizedString("termsVC_dismissButton", comment: ""), for: [])
        view.titleLabel?.font = UIFont.appTitle()
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.backgroundColor = UIColor.appGreen()
        view.setTitleColor(UIColor.darkGray, for: .highlighted)
        view.setTitleColor(UIColor.appWhite(), for: [])
        view.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowOpacity = Float.shadowOpacity()
        view.layer.shadowOffset = CGSize.shadowOffset()
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        let headerViewContainer: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(header)
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            header.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return view
        }()
        
        let textViewContainer: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            view.addSubview(textView)
            textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return view
        }()
        
        stackView.addArrangedSubview(headerViewContainer)
        stackView.addArrangedSubview(textViewContainer)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(acceptButton)
        return stackView
    }()
    
    var stack: UIStackView?
    private var heightAnchor = NSLayoutConstraint()
    private let terms: Terms
    var wasDismissed: (() -> Void)?
    
    init(terms: Terms) {
        self.terms = terms
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maxHeight: CGFloat = (UIScreen.main.bounds.height / 4) * 3

        if contentStackView.frame.height >= (maxHeight) {
            heightAnchor.constant = maxHeight
        } else {
            heightAnchor.constant = contentStackView.frame.height
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.backgroundColor = UIColor.appSecondaryColour()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.layer.cornerRadius = 16
            scrollView.addSubview(contentStackView)
            
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            return scrollView
        }()
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        heightAnchor = scrollView.heightAnchor.constraint(equalToConstant: 30)
        heightAnchor.isActive = true
    }
    
    private func configure() {
        switch terms {
        case .deleteImageTip:
            header.configure(title: NSLocalizedString("Deletions are final", comment: ""))
            textView.text = NSLocalizedString("When editing an observation, deletions of images are final, even if you do not submit your other changes. This message will only be shown once, and if you still want to delete the image, you will have to delete the it again", comment: "")
        case .mlPredict:
            header.configure(title: NSLocalizedString("termsVC_mlPredict_title", comment: ""))
            
            textView.text = NSLocalizedString("termsVC_mlPredict_message", comment: "")
        case .localityHelper:
            header.configure(title: NSLocalizedString("Remember to confirm your position", comment: ""))
            textView.text = NSLocalizedString("It is important for the quality of your collected data, that you make sure the position of the observation you are submitting are correct. You can see on the clip below how to adjust the position manually.\n\nIf a photo added to the observation contains a GPS tag, the app will suggest using the position from the image instead\n\nWe will remind you of this every once in a while. You can turn this reminder off in the settings.", comment: "")
            imageView.loadGif(name: "LocalityHelper")
            imageView.heightAnchor.constraint(equalToConstant: 276).isActive = true
        case .cameraHelper:
            header.configure(title: NSLocalizedString("termsVC_cameraHelper_title", comment: ""))
            textView.text = NSLocalizedString("termsVC_cameraHelper_message", comment: "")
        case .whatsNew:
            header.configure(title: NSLocalizedString("Whats new?", comment: ""))
            textView.text = NSLocalizedString("whats_new_2_0", comment: "")
        }
    }
    
    @objc private func acceptButtonPressed() {
        switch terms {
        case .whatsNew:
            UserDefaultsHelper.hasSeenWhatsNew = true
            case .mlPredict:
                UserDefaultsHelper.setHasAcceptedImagePredictionTerms(true)
        case .localityHelper:
            UserDefaultsHelper.setHasShownPositionReminder()
        default: break
        }
    
        wasDismissed?()
        dismiss(animated: true, completion: nil)
    }
}
