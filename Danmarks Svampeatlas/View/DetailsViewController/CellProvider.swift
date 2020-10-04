//
//  CellProvider.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 02/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import ELKit

enum Item {
    case observation(observation: Observation)
}

class CellProvider: ELTableViewCellProvider {
    typealias CellItem = Item
    
    func registerCells(tableView: UITableView) {
        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
    }
    
    func heightForItem(_ item: CellItem, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        switch item {
        case .observation: return UITableView.automaticDimension
        }
    }
    
    func cellForItem(_ item: Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .observation(observation: let observation):
            return (tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath)).then({($0 as? ObservationCell)?.configure(observation: observation)})
        }
    }
}
