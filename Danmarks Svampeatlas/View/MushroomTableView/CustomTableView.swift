//
//  MushroomTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
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
    
    private let actionButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitleColor(UIColor.appThird(), for: [])
        button.isHidden = true
        button.addTarget(self, action: #selector(actionButtonPressed), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    private var handler: (() -> ())?
    
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
        handler?()
    }
    
    func configure(mainTitle: String?, secondaryTitle: String?, handler: (() -> ())?) {
        if let mainTitle = mainTitle {
            mainLabel.text = mainTitle
            mainLabel.isHidden = false
        }
        
        if let secondaryTitle = secondaryTitle {
            secondaryLabel.text = secondaryTitle
            secondaryLabel.isHidden = false
        }
        
        if let handler = handler {
            actionButton.isHidden = false
            actionButton.setTitle("Do it", for: [])
            self.handler = handler
        }
    }
}

class AppTableView: UITableView {
    
    private var animating: Bool
    private var spinner = Spinner()
    
    init(animating: Bool, frame: CGRect, style: UITableView.Style) {
        self.animating = animating
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func reloadData() {
        super.reloadData()
        if self.visibleCells.count > 0 {
        self.backgroundView = nil
        guard animating == true else {return}
        
        
            var delayCounter = 0.0
            for cell in self.visibleCells {
                cell.contentView.alpha = 0
                UIView.animate(withDuration: 0.2, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                    cell.contentView.transform = CGAffineTransform.identity
                    cell.contentView.alpha = 1
                }, completion: nil)
                delayCounter = delayCounter + 0.10
            }
         self.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
    }
    
    func showLoader() {
        DispatchQueue.main.async {
            self.backgroundView = UIView(frame: self.frame)
            self.spinner.addTo(view: self.backgroundView!)
            self.spinner.start()
        }
    }
    
    func showError(_ appError: AppError, handler: (() -> ())?) {
        DispatchQueue.main.async {
            let view = BackgroundView()
            view.configure(mainTitle: appError.errorTitle, secondaryTitle: appError.errorDescription, handler: handler)
            self.backgroundView = view
        }
    }
}
