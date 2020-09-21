//
//  SettingsVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 21/09/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

extension ELTableView {
    static func build(provider: Providor) -> ELTableView<T, Providor> {
        return ELTableViewBuilder.init(cellProvidor: provider).setSectionHeaderCell(cellClass: SectionHeaderView.self).build()
    }
}

class SettingsVC: UIViewController {
    
    enum Item {
        case header
        case language
    }
    
    class CellProvider: ELTableViewCellProvider {
        func heightForItem(_ item: SettingsVC.Item, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        typealias CellItem = Item
        
        func registerCells(tableView: UITableView) {
            tableView.register(SettingsInformationCell.self, forCellReuseIdentifier: SettingsInformationCell.identifier)
            tableView.register(LanguageSettingCell.self, forCellReuseIdentifier: LanguageSettingCell.identifier)
        }
        
        func cellForItem(_ item: SettingsVC.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch item {
            case .header: return tableView.dequeueReusableCell(withIdentifier: SettingsInformationCell.identifier, for: indexPath)
            case .language: return tableView.dequeueReusableCell(withIdentifier: LanguageSettingCell.identifier, for: indexPath)
            }
        }
        
    }
    
    private lazy var tableView = ELTableView<Item, CellProvider>.build(provider: CellProvider()).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setSections(sections: [.init(title: nil, state: .items(items: [.header])), .init(title: "App sprog", state: .items(items: [.language]))])
        $0.didSelectItem.observe { (value) in
            switch value.Item {
            case .language: return
            default: return
            }
        }
    })
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        title = NSLocalizedString("navigationItem_settings", comment: "")
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
        
        view.addSubview(tableView)
        ELSnap.snapView(tableView, toSuperview: view)
        
    }
    
}
