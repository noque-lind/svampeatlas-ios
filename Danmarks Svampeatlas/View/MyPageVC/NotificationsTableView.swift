//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NotificationsTableView: GenericTableView<UserNotification> {
    
    override func setupView() {
        register(NotificationCell.self, forCellReuseIdentifier: "notificationCell")
        tableView.separatorColor = UIColor.appPrimaryColour()
        tableView.tintColor = UIColor.appWhite()
        super.setupView()
    }
    
    func removeNotification(notification: UserNotification) {
        var currentItems = tableViewState.currentItems()
        var maxCount = currentItems.count
        
        switch tableViewState {
        case .Paging(items: _, max: let max):
            maxCount = max ?? currentItems.count
        default: break
        }
        
        currentItems.removeAll(where: {$0.observationID == notification.observationID})
        
        if currentItems.count < maxCount {
            tableViewState = .Paging(items: currentItems, max: maxCount)
        } else {
            tableViewState = .Items(currentItems)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let notification = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
            cell.configureCell(notification: notification)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(type: .showMore)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableViewState.value(row: indexPath.row) == nil {
            return 90
        } else {
            return UITableView.automaticDimension
        }
    }
    }
