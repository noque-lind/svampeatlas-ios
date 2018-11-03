//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NotificationsTableView: UIView {
    
    private lazy var tableView: CustomTableView = {
        let tableView = CustomTableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.appSecondaryColour()
        tableView.alwaysBounceVertical = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "notificationCell")
        return tableView
    }()
    
    private var notifications = [UserNotification]()
    weak var delegate: NavigationDelegate?
    
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
 
    
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func configure(notifications: [UserNotification]) {
            heightAnchor.constraint(equalToConstant: 90 * CGFloat(notifications.count)).isActive = true
            tableView.panGestureRecognizer.isEnabled = false
            self.notifications = notifications
            tableView.reloadData()
        }
    }


extension NotificationsTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        cell.configureCell(notification: notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailsViewController(detailsContent: DetailsContent.observationWithID(observationID: notifications[indexPath.row].observationID, showSpeciesView: true))
        delegate?.pushVC(vc)
    }
    }


