//
//  NewTableView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 20/09/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import ELKit

//class NewTableView: ELTableView<> {
//
//    enum Item {
//        case selectedMushroom(Mushroom, NewObservation.DeterminationConfidence)
//        case selectableMushroom(Mushroom, Double?)
//        case unknownSpecies
//        case unknownSpeciesButton
//        case citation
//        case lowConfidence
//    }
//
//    var isAtTop: ((Bool) -> ())?
//    var confidenceSelected: ((NewObservation.DeterminationConfidence) -> ())?
//
//
//    override init() {
//        super.init()
//        register(cellClass: UnknownSpecieCell.self, forCellReuseIdentifier: UnknownSpecieCell.identifier)
//        register(cellClass: ContainedResultCell.self, forCellReuseIdentifier: ContainedResultCell.identifier)
//        register(cellClass: SelectedSpecieCell.self, forCellReuseIdentifier: SelectedSpecieCell.identifier)
//        register(cellClass: UnknownSpeciesCellButton.self, forCellReuseIdentifier: UnknownSpeciesCellButton.identifier)
//        register(cellClass: CreditationCell.self, forCellReuseIdentifier: CreditationCell.identifier)
//        register(cellClass: CautionCell.self, forCellReuseIdentifier: CautionCell.identifier)
//        tintColor = .appWhite()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//
//    override func cellForItem(_ item: AddObservationMushroomTableView.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
//        switch item {
//        case .selectableMushroom(let mushroom, let confidence):
//            let cell = tableView.dequeueReusableCell(withIdentifier: ContainedResultCell.identifier, for: indexPath) as! ContainedResultCell
//
//            if let confidence = confidence {
//                cell.configureCell(mushroom: mushroom, confidence: confidence)
//            } else {
//                cell.configureCell(mushroom: mushroom)
//            }
//
//            cell.accessoryType = .disclosureIndicator
//            cell.tintColor = UIColor.appWhite()
//            return cell
//
//        case .selectedMushroom(let mushroom, let confidence):
//            let cell = tableView.dequeueReusableCell(withIdentifier: SelectedSpecieCell.identifier, for: indexPath) as! SelectedSpecieCell
//            cell.configureCell(mushroom: mushroom, confidence: confidence)
//            cell.confidenceSelected = confidenceSelected
//            cell.accessoryType = .none
//            return cell
//
//        case .unknownSpecies:
//            let cell = tableView.dequeueReusableCell(withIdentifier: UnknownSpecieCell.identifier, for: indexPath) as! UnknownSpecieCell
//
//            return cell
//        case .unknownSpeciesButton:
//            let cell = tableView.dequeueReusableCell(withIdentifier: UnknownSpeciesCellButton.identifier, for: indexPath) as! UnknownSpeciesCellButton
//            return cell
//        case .citation:
//            let cell = tableView.dequeueReusableCell(withIdentifier: CreditationCell.identifier, for: indexPath) as! CreditationCell
//            cell.configureCell(creditation: .AINewObservation)
//            return cell
//        case .lowConfidence:
//            let cell = tableView.dequeueReusableCell(withIdentifier: CautionCell.identifier, for: indexPath) as! CautionCell
//            cell.configureCell(type: .lowConfidence)
//            return cell
//        }
//    }
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
//            isAtTop?(true)
//        } else {
//            isAtTop?(false)
//        }
//    }
//}
