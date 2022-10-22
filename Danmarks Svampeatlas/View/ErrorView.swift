//
//  ErrorView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 13/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import UIKit

class ErrorView: UIView {
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var actionButton = UIButton().then({
        $0.setTitleColor(UIColor.appThird(), for: [])
        $0.titleLabel?.font = UIFont.appPrimaryHightlighed()
        $0.isHidden = true
        $0.addTarget(self, action: #selector(actionButtonPressed), for: UIControl.Event.touchUpInside)
    })

    
    private var handler: ELHandler?
    private var recoveryAction: RecoveryAction?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let contentStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.addArrangedSubview(mainLabel)
            stackView.addArrangedSubview(secondaryLabel)
            stackView.addArrangedSubview(actionButton)
            return stackView
        }()
        
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    @objc private func actionButtonPressed() {
        handler?(recoveryAction)
    }
    
    func configure(error: AppError, handler: ((RecoveryAction?) -> Void)?) {
        mainLabel.text = error.title
        secondaryLabel.text = error.message
        
        if let recoveryAction = error.recoveryAction, handler != nil {
            actionButton.setTitle(recoveryAction.localizableText, for: [])
            actionButton.isHidden = false
            self.handler = handler
            self.recoveryAction = recoveryAction
        }
    }
    
    func configure(error: ELError, handler: ELHandler?) {
        mainLabel.text = error.title
        secondaryLabel.text = error.message
        
        if let recoveryAction = error.recoveryAction, handler != nil {
            actionButton.setTitle(recoveryAction.localizableText, for: [])
            actionButton.isHidden = false
            self.handler = handler
            self.recoveryAction = recoveryAction
        }
    }
}
