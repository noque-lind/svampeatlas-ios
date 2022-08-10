//
//  MushroomTableView.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 06/06/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomTableView: ELTableViewOld<MushroomTableView.Item> {
    
    enum Item {
        case mushroom(Mushroom)
        case loadMore(offset: Int)
    }
    
    var mushroomSwiped: ((Mushroom, IndexPath) -> Void)?
    var isAtTop: ((Bool) -> Void)?
    
    override init() {
        super.init()
        register(cellClass: MushroomCell.self, forCellReuseIdentifier: MushroomCell.identifier)
        register(cellClass: ReloadCell.self, forCellReuseIdentifier: ReloadCell.identifier)
    }
    
    deinit {
        debugPrint("MushroomTableView deinited")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func cellForItem(_ item: MushroomTableView.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .mushroom(let mushroom):
            let cell = tableView.dequeueReusableCell(withIdentifier: MushroomCell.identifier, for: indexPath) as! MushroomCell
            cell.configureCell(mushroom: mushroom)
            return cell
        case .loadMore:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReloadCell.identifier, for: indexPath) as! ReloadCell
            cell.configureCell(type: .showMore)
            return cell
        }
    }
    
    override func heightForItem(_ item: MushroomTableView.Item) -> CGFloat {
        switch item {
        case .loadMore:
            return LoaderCell.height
        case .mushroom:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = sections[indexPath.section].itemAt(index: indexPath.row), case Item.mushroom(let mushroom) = item else {return nil}
        let action = UIContextualAction(style: .normal, title: nil) { (_, _, completion) in
            self.mushroomSwiped?(mushroom, indexPath)
            completion(true)
        }
        
        action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        action.image = Database.instance.mushroomsRepository.exists(mushroom: mushroom) ? #imageLiteral(resourceName: "Icons_Utils_Favorite_DeMake"): #imageLiteral(resourceName: "Icons_Utils_Favorite_Make")
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
