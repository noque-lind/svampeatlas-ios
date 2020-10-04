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
            tableView.register(SettingCell.self, forCellReuseIdentifier: String(describing: SettingCell.self))
        }
        
        func cellForItem(_ item: SettingsVC.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch item {
            case .header:
                return tableView.dequeueReusableCell(withIdentifier: SettingsInformationCell.identifier, for: indexPath)
            case .language: return tableView.dequeueReusableCell(withIdentifier: String(describing: SettingCell.self), for: indexPath).then({
                ($0 as? SettingCell)?.configureCell(icon: nil, description: NSLocalizedString("settingsCell_language", comment: ""), content: Locale.current.localizedString(forIdentifier: Locale.current.identifier)?.capitalizeFirst() ?? "")
            })
            }
        }
        
    }
    
    private lazy var tableView = ELTableView<Item, CellProvider>.build(provider: CellProvider()).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setSections(sections: [.init(title: nil, state: .items(items: [.header])), .init(title: NSLocalizedString("settings_general_header", comment: ""), state: .items(items: [.language]))])
        $0.didSelectItem.observe { (value) in
            switch value.Item {
            case .language: UIApplication.openAppSettings()
            default: return
            }
        }
    })
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: false)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView() {
        title = NSLocalizedString("navigationItem_settings", comment: "")
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
        
        _ = GradientView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            ELSnap.snapView($0, toSuperview: view, ignoreSafeAreaInsets: true)
        })
        
        view.addSubview(tableView)
        ELSnap.snapView(tableView, toSuperview: view)
        
    }
    
}
