//
//  SideMenuController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NavigationVC: UITableViewController {
    
    private var firstLoad = true
    private let navigationItems = [[NavigationItem.init(title: "Nyt fund", icon: #imageLiteral(resourceName: "Plus"), viewControllerIdentifier: "NewObservationVC"), NavigationItem.init(title: "Start felttur", icon: #imageLiteral(resourceName: "Walk"), viewControllerIdentifier: "FieldWalkVC")], [NavigationItem.init(title: "Svampe-bog", icon: #imageLiteral(resourceName: "Book"), viewControllerIdentifier: "MainVC"), NavigationItem.init(title: "Artsbestemmelse", icon: #imageLiteral(resourceName: "Camera"), viewControllerIdentifier: "RecognizeVC")]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        tableView.register(NavigationCell.self, forCellReuseIdentifier: "navigationCell")
        clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstLoad {
            tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .top)
            firstLoad = false
        }
        super.viewWillAppear(animated)
    }
}

extension NavigationVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return navigationItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "navigationCell", for: indexPath) as! NavigationCell
        cell.configureCell(navigationItem: navigationItems[indexPath.section][indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc: UIViewController?
        
        let identifier = navigationItems[indexPath.section][indexPath.row].viewControllerIdentifier
        switch identifier {
        case "RecognizeVC":
            vc = UINavigationController(rootViewController: RecognizeVC(isObservation: false))
        case "NewObservationVC":
            vc = NewObservationVC()
        case "FieldWalkVC":
            vc = FieldWalkVC()
        default:
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: navigationItems[indexPath.section][indexPath.row].viewControllerIdentifier)
        }
    self.eLRevealViewController()?.pushNewViewController(viewController: vc!)
    }
}
