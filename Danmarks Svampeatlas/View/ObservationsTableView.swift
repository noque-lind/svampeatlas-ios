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
        register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        super.setupView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath) as! ObservationCell
            cell.configure(observation: item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(text: "Vis flere")
            return cell
        }
    }

}
    
//    ´Type´ {
//        case userObservations(totalNumberOfObservations: Int)
//        case speciesObservations(mushroomID: Int)
//        case observations(observations: [Observation])
//        case error(error: AppError)
//    }
//
//    private var type: ´Type´?
//
//    override func setupView() {
//        tableViewState = .Loading
//
//        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
//        tableView.register(ReloadCell.self, forCellReuseIdentifier: "reloadCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        super.setupView()
//    }
//
//    func configure(type: ´Type´) {
//        self.type = type
//        getObservations(offset: 0)
//    }
//
//    private func getObservations(offset: Int) {
//        guard let type = type else {return}
//        var currentItems = tableViewState.currentItems()
//        tableViewState = .Loading
//
//        switch type {
//        case .error(error: let error):
//            tableViewState = .Error(error, nil)
//        case .observations(observations: let observations):
//            tableViewState = .Items(observations, offSet: nil)
//        case .speciesObservations(mushroomID: let id):
//            DataService.instance.getObservationsForMushroom(withID: id, limit: 10, offset: offset) { (result) in
//                switch result {
//                case .Error(let error):
//                    self.tableViewState = .Error(error, nil)
//                case .Success(let observations):
//                    currentItems.append(contentsOf: observations)
//                    self.tableViewState = .Items(currentItems, offSet: offset)
//                }
//            }
//        case .userObservations(totalNumberOfObservations: _):
//            return
////            Session.instance.getUserObservations(limit: 10, offset: offset) { (result) in
////                switch result {
////                case .Error(let error):
////                    self.tableViewState = TableViewState.Error(error, nil)
////                case .Success(let observations):
////                    currentItems.append(contentsOf: observations)
////                    self.tableViewState = TableViewState.Items(currentItems, offSet: offset)
////                }
////            }
//        }
//    }

/*
 
 
extension ObservationsTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = type else {return 0}
        let itemsCount = tableViewState.itemsCount()
        
        switch type {
        case .error(error: _), .observations(observations: _):
            return itemsCount
        case .speciesObservations(mushroomID: _):
            return itemsCount + 1
        case .userObservations(totalNumberOfObservations: let count):
            if count == itemsCount {
                return itemsCount
            } else {
                return itemsCount + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let observation = tableViewState.value(row: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath) as! ObservationCell
            cell.configure(observation: observation)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(text: "Vis flere")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ReloadCell {
            if tableView.cellForRow(at: indexPath) is ReloadCell {
                getObservations(offset: tableViewState.itemsCount())
            }
        } else {
            guard let observation = tableViewState.value(row: indexPath.row) else {return}
            delegate?.pushVC(DetailsViewController(detailsContent: .observation(observation: observation, showSpeciesView: true)))
        }
    }
}
*/

