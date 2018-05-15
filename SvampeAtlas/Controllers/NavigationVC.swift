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
    private let navigationItems = [NavigationItem.init(title: "Svampe-bog", icon: #imageLiteral(resourceName: "LogoSmall"), viewControllerIdentifier: "MainVC"), NavigationItem.init(title: "Artsbestemmelse", icon: #imageLiteral(resourceName: "Camera"), viewControllerIdentifier: "RecognizeVC")]
    

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
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            firstLoad = false
        }
        super.viewWillAppear(animated)
    }
}

extension NavigationVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "navigationCell", for: indexPath) as! NavigationCell
        cell.configureCell(navigationItem: navigationItems[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: navigationItems[indexPath.row].viewControllerIdentifier)
        self.eLRevealViewController()?.pushNewViewController(viewController: vc)
    }
}
