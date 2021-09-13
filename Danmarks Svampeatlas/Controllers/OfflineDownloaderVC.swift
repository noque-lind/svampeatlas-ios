//
//  OfflineDownloaderVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 31/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class OfflineDownloader: UIViewController {
    
    private let header = UIView().then({ view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let header = SectionHeaderView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.configure(title:  NSLocalizedString("Downloading offline data", comment: ""))
        })
        view.addSubview(header)
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        header.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    })
    
    private let messageLabel = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .appPrimaryHightlighed()
        $0.textColor = .appWhite()
        $0.textAlignment = .center
    })
    
    private let spinner = Spinner().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = .cornerRadius()
        $0.clipsToBounds = true
    })
    
    private var heightAnchor = NSLayoutConstraint()
    
    private let viewModel = DownloaderviewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxHeight: CGFloat = (UIScreen.main.bounds.height / 4) * 3
            heightAnchor.constant = maxHeight
    }
    
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let contentView = UIView().then({
            heightAnchor = $0.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height / 4) * 3)
            heightAnchor.isActive = true
            $0.backgroundColor = .appSecondaryColour()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            let stackView = UIStackView().then({
                $0.axis = .vertical
                $0.spacing = 16
                $0.addArrangedSubview(header)
                $0.addArrangedSubview(messageLabel)
                $0.addArrangedSubview(spinner)
            })
            $0.addSubview(stackView)
            ELSnap.snapView(stackView, toSuperview: $0)
        })
        
        view.do({
            $0.addSubview(contentView)
        })
        
        contentView.do({
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
            $0.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        })
    }
    
    private func configureViewModel() {
            viewModel.state.observe { [weak self] value in
                DispatchQueue.main.async {
                switch value {
                case .Loading(message: let message):
                    self?.spinner.start()
                    self?.messageLabel.text = message
                case .Completed:
                    ELNotificationView.appNotification(style: .success, primaryText: NSLocalizedString("Success", comment: ""), secondaryText: NSLocalizedString("Your device now has the newest update to the taxon database. Get out there!", comment: ""), location: .bottom).show(animationType: .fromBottom, queuePosition: .front, onViewController: nil)
                    self?.dismiss(animated: true, completion: nil)
                case .Error(error: let error):
                    ELNotificationView.appNotification(style: .error(actions: [.neutral(NSLocalizedString("Try again", comment: ""), {
                    })]), primaryText: error.title, secondaryText: error.message, location: .bottom).show(animationType: .fromBottom)
                default: self?.spinner.stop()
                }
            }
        }
    }
    
}



