//
//  NotificationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


class NotificationsTableView: GenericTableView, UITableViewDataSource, UITableViewDelegate {
    
    private var notifications = [UserNotification]()
    private var totalNumberOfNotifications = 0
    private var userID: Int = 0
    
    override func setupView() {
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "notificationCell")
        tableView.delegate = self
        tableView.dataSource = self
        super.setupView()
    }
    
    func configure(notifications: [UserNotification], totalNumberOfNotifications: Int, userID: Int) {
        self.notifications = notifications
        self.totalNumberOfNotifications = totalNumberOfNotifications
        self.userID = userID
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalNumberOfNotifications != notifications.count {
            return notifications.count + 1
        } else {
            return notifications.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row + 1 == notifications.count + 1 {
            return ReloadCell(labelText: "Vis flere", reuseIdentifier: "")
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
            cell.configureCell(notification: notifications[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ReloadCell {
            DataService.instance.getNotificationsForUser(withID: userID, limit: totalNumberOfNotifications, offset: 0) { (appError, notifications) in
                guard let notifications = notifications else {return}
                
                DispatchQueue.main.async {
                    self.notifications = notifications
                    self.tableView.reloadData()
                }
            }
        } else {
            self.controlActivityIndicator(wantRunning: true)
            DataService.instance.getObservation(withID: notifications[indexPath.row].observationID) { (appError, observation) in
                
                DispatchQueue.main.async {
                    self.controlActivityIndicator(wantRunning: false)
                }
                
                
                guard let observation = observation else {self.delegate?.pushVC(UIAlertController(title: appError!.title, message: appError!.message)); return}
                DispatchQueue.main.async {
                    let vc = DetailsViewController(detailsContent: DetailsContent.observation(observation: observation, showSpeciesView: true))
                    self.delegate?.pushVC(vc)
                }
                
            }
        }
    }
    
    
}
