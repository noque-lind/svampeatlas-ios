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
        super.setupView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let notification = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
            cell.configureCell(notification: notification)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(text: "Vis flere")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableViewState.value(row: indexPath.row) == nil {
            return 90
        }
        else {
            return UITableView.automaticDimension
        }
       
    }
    }
