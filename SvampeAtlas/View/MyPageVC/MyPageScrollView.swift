//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MyPageScrollView: UIScrollView {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appPrimaryColour()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    private lazy var notificationsCountLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = UIColor.appRed()
            label.textAlignment = .center
        label.font = UIFont.appPrimaryHightlighed()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.appWhite()
            label.widthAnchor.constraint(equalTo: label.heightAnchor).isActive = true
            label.clipsToBounds = true
            label.layer.cornerRadius = 10
        return label
    }()
    
    
    weak var customDelegate: NavigationDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func configure(user: User) {
        setupNotifications(userID: user.id)
        setupObservations(userID: user.id)
    }
    
    private func setupObservations(userID: Int) {
        let stackView: UIStackView = {
           let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 5
            
            let label: UILabel = {
               let label = UILabel()
                label.text = "Dine observationer"
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                return label
            }()
            
            let observationsTableView: ObservationsTableView = {
               let tableView = ObservationsTableView(automaticallyAdjustHeight: true)
                tableView.delegate = self.customDelegate
                DataService.instance.getObservationsForUser(withID: userID) { (appError, observations) in
                    guard let observations = observations else {return}
                    DispatchQueue.main.async {
                        tableView.configure(observations: observations)
                    }
                }
                return tableView
            }()
    
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(observationsTableView)
            return stackView
        }()
        
        contentStackView.addArrangedSubview(stackView)
    }
    
    private func setupNotifications(userID: Int) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 0
            
            let labelStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 5
                
                let label: UILabel = {
                    let label = UILabel()
                    label.text = "Notifikationer"
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    return label
                }()
                
                stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                stackView.addArrangedSubview(notificationsCountLabel)
                stackView.addArrangedSubview(label)
                return stackView
            }()
        
            let notificationsTableView: NotificationsTableView = {
                let tableView = NotificationsTableView()
                tableView.delegate = self.customDelegate
                
                UserService.instance.getUserNotificationCount(completion: { (count) in
                    guard let count = count else {return}
                    DispatchQueue.main.async {
                        self.notificationsCountLabel.text = "\(count)"
                    }
                    
                    let limit = count >= 3 ? 3: count
                    
                    DataService.instance.getNotificationsForUser(withID: userID, limit: limit, offset: 0, completion: { (appError, userNotifications) in
                        DispatchQueue.main.async {
                            guard let userNotifications = userNotifications else {return}
                            tableView.configure(notifications: userNotifications, totalNumberOfNotifications: count, userID: userID)
                        }
                    })
                    
                })
                
                
                return tableView
            }()
            
            stackView.addArrangedSubview(labelStackView)
            stackView.addArrangedSubview(notificationsTableView)
            return stackView
        }()
        
        contentStackView.addArrangedSubview(stackView)
    }
}
