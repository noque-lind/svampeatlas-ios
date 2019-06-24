//
//  MushroomTableView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/06/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomTableView: GenericTableView<Mushroom> {
    
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            tableView.contentInset = self.contentInset
        }
    }
    
    var scrollIndicatorInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            tableView.scrollIndicatorInsets = self.scrollIndicatorInsets
        }
    }
    
    var mushroomSwiped: ((Mushroom) -> ())?
    var isAtTop: ((Bool) -> ())?
    
    override func setupView() {
        register(MushroomCell.self, forCellReuseIdentifier: "mushroomCell")
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        super.setupView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let mushroom = tableViewState.value(row: indexPath.row), let cell = tableView.dequeueReusableCell(withIdentifier: "mushroomCell", for: indexPath) as? MushroomCell {
            cell.configureCell(mushroom: mushroom)
            return cell
        } else {
            let reloadCell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            reloadCell.configureCell(text: "Vis flere")
            return reloadCell
        }
    }
    
    deinit {
        print("mushroomTableViewDeinit")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == tableViewState.itemsCount() {
            return 200
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let mushroom = self.tableViewState.value(row: indexPath.row) else {return nil}
        
        let action = UIContextualAction(style: .normal, title: nil) { [unowned self] (action, view, completion) in
            self.mushroomSwiped?(mushroom)
            completion(true)
        }
        
        action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        action.image = CoreDataHelper.mushroomAlreadyFavorited(mushroom: mushroom) ? #imageLiteral(resourceName: "Icon_DeFavorite"): #imageLiteral(resourceName: "Favorite")
         return UISwipeActionsConfiguration(actions: [action])
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            isAtTop?(true)
        } else {
            isAtTop?(false)
        }
    }
}
