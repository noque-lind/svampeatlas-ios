//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

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
        view.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMaxXMaxYCorner, CACornerMask.layerMinXMaxYCorner]
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    private lazy var notificationsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appDivider()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.appWhite()
        label.isHidden = true
        return label
    }()
    
    private lazy var notificationsTableView: NotificationsTableView = {
       let view = NotificationsTableView(automaticallyAdjustHeight: true)
        return view
    }()
    
    private lazy var observationsTableView: ObservationsTableView = {
        let view = ObservationsTableView(automaticallyAdjustHeight: true)
        return view
    }()
    
    private lazy var observationsCountLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appDivider()
        label.textColor = UIColor.appWhite()
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        label.isHidden = true
        return label
    }()
    
    
    private lazy var logoutButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Icons_LogOut") , for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private var session: Session

    weak var navigationDelegate: NavigationDelegate?
    
    init(session: Session) {
        self.session = session
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    deinit {
        debugPrint("MyPageScrollView deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        
        addSubview(logoutButton)
        logoutButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let logoutLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = "Log ud"
            label.heightAnchor.constraint(equalToConstant: 30).isActive = true
            return label
        }()
    
        addSubview(logoutLabel)
        logoutLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoutLabel.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -10).isActive = true
        
       
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: logoutLabel.topAnchor, constant: -32).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        let notificationsStackView: UIStackView = {
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
                    label.font = UIFont.appDivider()
                    label.textColor = UIColor.appWhite()
                    return label
                }()
                
                stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                stackView.addArrangedSubview(notificationsCountLabel)
                stackView.addArrangedSubview(label)
                return stackView
            }()
            
            stackView.addArrangedSubview(labelStackView)
            stackView.addArrangedSubview(notificationsTableView)
            return stackView
        }()
        
        let observationsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 5
            
            let labelStackView: UIStackView = {
               let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 5
                
                let label: UILabel = {
                    let label = UILabel()
                    label.text = "Observationer"
                    label.font = UIFont.appDivider()
                    label.textColor = UIColor.appWhite()
                    return label
                }()
                
                stackView.addArrangedSubview(observationsCountLabel)
                stackView.addArrangedSubview(label)
                return stackView
            }()
            
            stackView.addArrangedSubview(labelStackView)
            stackView.addArrangedSubview(observationsTableView)
            return stackView
        }()
        
        contentStackView.addArrangedSubview(notificationsStackView)
        contentStackView.addArrangedSubview(observationsStackView)
        
        setupNotifications()
        setupObservations()
    }
    

    private func setupNotifications() {
        
            notificationsTableView.tableViewState = .Loading
            session.getNotificationCount { [weak notificationsCountLabel, weak session, weak notificationsTableView] (result) in
            switch result {
            case .Success(let count):
                DispatchQueue.main.async { [weak notificationsCountLabel] in
                    notificationsCountLabel?.text = "\(count)"
                    notificationsCountLabel?.isHidden = false
                }
                session?.getUserNotifications(limit: ((count <= 4) ? count: 4), offset: 0, completion: { [weak notificationsTableView] (result) in
                    switch result {
                    case .Error(let error):
                        notificationsTableView?.tableViewState = .Error(error, nil)
                    case .Success(let notifications):
                        if notifications.count < count {
                            notificationsTableView?.tableViewState = .Paging(items: notifications, max: count)
                        } else {
                            notificationsTableView?.tableViewState = .Items(notifications)
                        }
                    }
                })
            case .Error(let error):
                notificationsTableView?.tableViewState = .Error(error, nil)
            }
        }
        
        notificationsTableView.didRequestAdditionalDataAtOffset = { [unowned session] tableView, offset, max in
            var allNotifications = tableView.tableViewState.currentItems()
            tableView.tableViewState = .Loading
            
            session.getUserNotifications(limit: (max! <= 8) ? max!: 8, offset: offset, completion: { (result) in
                switch result {
                case .Error(let error):
                    tableView.tableViewState = .Error(error, nil)
                case .Success(let notifications):
                    allNotifications.append(contentsOf: notifications)
                    if allNotifications.count >= max! {
                        tableView.tableViewState = .Items(allNotifications)
                    } else {
                        tableView.tableViewState = .Paging(items: allNotifications, max: max!)
                    }
                }
            })
        }
        
        notificationsTableView.didSelectItem = {[unowned self] usernotification in
            let currentTableViewState = self.notificationsTableView.tableViewState
            self.notificationsTableView.tableViewState = .Loading
            
            DataService.instance.getObservation(withID: usernotification.observationID, completion: { [weak self] (result) in
                switch result {
                case .Error(let error):
                    let notif = ELNotificationView.appNotification(style: .error, primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .bottom)
                    notif.show(animationType: .fromBottom)
                case .Success(let observation):
                    self?.navigationDelegate?.pushVC(DetailsViewController(detailsContent: .observation(observation: observation, showSpeciesView: true, session: self?.session)))
                }
                self?.notificationsTableView.tableViewState = currentTableViewState
            })
        }
    }
    
    private func setupObservations() {
        observationsTableView.tableViewState = .Loading
        
        observationsTableView.didSelectItem = {[unowned self] item in
            self.navigationDelegate?.pushVC(DetailsViewController(detailsContent: .observation(observation: item, showSpeciesView: true, session: self.session)))
        }
        
        observationsTableView.didRequestAdditionalDataAtOffset = {[weak session] tableView, offset, max in
            var allObservations = tableView.tableViewState.currentItems()
            tableView.tableViewState = .Loading
            session?.getObservations(limit: (max! <= 15 ? max!: 15), offset: offset, completion: { (result) in
                switch result {
                case .Error(let error):
                    tableView.tableViewState = .Error(error, nil)
                case .Success(let observations):
                    allObservations.append(contentsOf: observations)
                    if let max = max, allObservations.count >= max{
                         tableView.tableViewState = .Items(allObservations)
                    } else {
                        tableView.tableViewState = .Paging(items: allObservations, max: max)
                    }
                }
            })
            
        }
        
        session.getObservationsCount { [weak self] (result) in
            switch result {
            case .Error(let error):
                self?.observationsTableView.tableViewState = .Error(error, nil)
            case .Success(let count):
                DispatchQueue.main.async {
                    self?.observationsCountLabel.text = "\(count)"
                    self?.observationsCountLabel.isHidden = false
                }
                self?.session.getObservations(limit: 15, offset: 0, completion: { (result) in
                    switch result {
                    case .Error(let error):
                        self?.observationsTableView.tableViewState = .Error(error, nil)
                    case .Success(let observations):
                        if observations.count == count {
                            self?.observationsTableView.tableViewState = .Items(observations)
                        } else {
                           self?.observationsTableView.tableViewState = .Paging(items: observations, max: count)
                        }
                    }
                })
            }
        }
    }
    
    @objc private func logoutButtonPressed() {
        session.logout()
        self.navigationDelegate?.presentVC(OnboardingVC())
    }
}
