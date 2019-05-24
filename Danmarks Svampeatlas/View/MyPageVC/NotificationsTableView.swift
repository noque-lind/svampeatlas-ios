//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol NotificationsTableViewDelegate {
    func didSelectItem(item: UserNotification)
}

extension NotificationsTableView: GenericTableViewDelegate {
    typealias Item = UserNotification
    
    func tableView(_ tableView: UITableView, didRequestAdditionalDataAtOffset offset: Int) {
        print("walala")
    }
    
    func tableView(_ tableView: UITableView, didSelectItem item: UserNotification) {
        print("walalal")
        customDelegate?.didSelectItem(item: item)
    }
    
    func presentVC(_ vc: UIViewController) {
        return
    }
    
    func pushVC(_ vc: UIViewController) {
        return
    }
}

class NotificationsTableView: GenericTableView<UserNotification> {
    
    override func setupView() {
        register(NotificationCell.self, forCellReuseIdentifier: "notificationCell")
        super.setupView()
    }
    
    var customDelegate: NotificationsTableViewDelegate?
    
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
        return 90
    }
    }
