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
        view.backgroundColor = UIColor.appSecondaryColour()
        view.layer.cornerRadius = 20
        view.layer.shadowOffset = CGSize(width: 0.0, height: -1.5)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.4
        view.layer.maskedCorners = [CACornerMask.layerMaxXMaxYCorner, CACornerMask.layerMinXMaxYCorner]
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    private lazy var notificationsCountLabel: SectionHeaderView = {
        let view = SectionHeaderView()
        view.configure(title: NSLocalizedString("myPageScrollView_notificationsHeader", comment: ""))
        return view
    }()
    
    private lazy var observationsCountLabel: SectionHeaderView = {
        let view = SectionHeaderView()
        view.configure(title: NSLocalizedString("myPageScrollView_observationsHeader", comment: ""))
        return view
    }()
    
    private lazy var notificationsTableView: NotificationsTableView = {
       let view = NotificationsTableView(automaticallyAdjustHeight: true)
        return view
    }()
    
    private lazy var observationsTableView: ObservationsTableView = {
        let view = ObservationsTableView(automaticallyAdjustHeight: true)
        return view
    }()
    
    private lazy var logoutButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_LogOut") , for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private var notificationsCount = 0
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
            label.text = NSLocalizedString("myPageScrollView_logout", comment: "")
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
            stackView.spacing = 8
            stackView.addArrangedSubview(notificationsCountLabel)
            
            let contentStackView: UIStackView = {
               let stackView = UIStackView()
                stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                stackView.addArrangedSubview(notificationsTableView)
                return stackView
            }()
            
            stackView.addArrangedSubview(contentStackView)
            return stackView
        }()
        
        let observationsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            
            stackView.addArrangedSubview(observationsCountLabel)
            
            let contentStackView: UIStackView = {
               let stackView = UIStackView()
                stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                stackView.addArrangedSubview(observationsTableView)
                return stackView
            }()
            
            stackView.addArrangedSubview(contentStackView)
            return stackView
        }()
        
        contentStackView.addArrangedSubview(notificationsStackView)
        contentStackView.addArrangedSubview(observationsStackView)
        
        setupNotifications()
        setupObservations()
    }
    

    private func setupNotifications() {
            notificationsTableView.tableViewState = .Loading
            session.getNotificationCount { [weak self, weak notificationsCountLabel, weak session, weak notificationsTableView] (result) in
            switch result {
            case .success(let count):
                self?.notificationsCount = count
                
                DispatchQueue.main.async { [weak notificationsCountLabel] in
                    notificationsCountLabel?.configure(title: "\(count) \(NSLocalizedString("myPageScrollView_notificationsHeader", comment: ""))")
                }
                
                session?.getUserNotifications(limit: ((count <= 4) ? count: 4), offset: 0, completion: { [weak notificationsTableView] (result) in
                    switch result {
                    case .failure(let error):
                        notificationsTableView?.tableViewState = .Error(error, nil)
                    case .success(let notifications):
                        if notifications.count < count {
                            notificationsTableView?.tableViewState = .Paging(items: notifications, max: count)
                        } else {
                            notificationsTableView?.tableViewState = .Items(notifications)
                        }
                    }
                })
            case .failure(let error):
                notificationsTableView?.tableViewState = .Error(error, nil)
            }
        }
        
        notificationsTableView.didRequestAdditionalDataAtOffset = { [unowned session] tableView, offset, max in
            tableView.tableViewState = .Loading
            
            session.getUserNotifications(limit: (max! >= offset + 8) ? offset + 8: max!, offset: offset, completion: { (result) in
                switch result {
                case .failure(let error):
                    tableView.tableViewState = .Error(error, nil)
                case .success(let notifications):
                    if notifications.count >= max! {
                        tableView.tableViewState = .Items(notifications)
                    } else {
                        tableView.tableViewState = .Paging(items: notifications, max: max!)
                    }
                }
            })
        }
        
        notificationsTableView.didSelectItem = {[unowned self] usernotification in
            if self.notificationsCount > 1 {
                 self.notificationsCount -= 1
                self.notificationsTableView.removeNotification(notification: usernotification)
            } else {
                self.notificationsCount = 0
                self.notificationsTableView.tableViewState = .Error(Session.SessionError.noNotifications, nil)
            }
           
            self.notificationsCountLabel.configure(title: "\(self.notificationsCount) \(NSLocalizedString("myPageScrollView_notificationsHeader", comment: ""))")
            self.session.markNotificationAsRead(notificationID: usernotification.observationID)
            self.navigationDelegate?.pushVC(DetailsViewController(detailsContent: .observationWithID(observationID: usernotification.observationID, showSpeciesView: true, session: self.session)))
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
                case .failure(let error):
                    tableView.tableViewState = .Error(error, nil)
                case .success(let observations):
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
            case .failure(let error):
                self?.observationsTableView.tableViewState = .Error(error, nil)
            case .success(let count):
                DispatchQueue.main.async {
                    self?.observationsCountLabel.configure(title: "\(count) \(NSLocalizedString("myPageScrollView_observationsHeader", comment: ""))")
                }
                self?.session.getObservations(limit: 15, offset: 0, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        self?.observationsTableView.tableViewState = .Error(error, nil)
                    case .success(let observations):
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
        (UIApplication.shared.delegate as? AppDelegate)?.session = nil
    }
}
