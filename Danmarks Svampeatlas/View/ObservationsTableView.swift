//
//  ObservationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


class ObservationsTableView: GenericTableView<Observation> {

    weak var navigationDelegate: NavigationDelegate?
    
    override func setupView() {
        tableView.separatorColor = UIColor.appPrimaryColour()
        tableView.rowHeight = UITableView.automaticDimension
        register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        super.setupView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableViewState.value(row: indexPath.row) == nil {
            return 90
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath) as! ObservationCell
            cell.configure(observation: item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(type: .showMore)
            return cell
        }
    }

}

