//
//  SideMenuController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NavigationVC: UIViewController {
    
    private var gradientView: GradientView = {
       let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(NavigationCell.self, forCellReuseIdentifier: "navigationCell")
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
//        tableView.clearsSelectionOnViewWillAppear = false
        tableView.tableHeaderView = userView
        return tableView
    }()
    
    private lazy var userView: UserView = {
       let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = []
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        return view
    }()
    
    private var firstLoad = true
    private let navigationItems = [[NavigationItem.init(title: "Login", icon: #imageLiteral(resourceName: "Exit"), viewControllerIdentifier: "LoginVC")], [NavigationItem.init(title: "Nyt fund", icon: #imageLiteral(resourceName: "Plus"), viewControllerIdentifier: "NewObservationVC"), NavigationItem.init(title: "Start felttur", icon: #imageLiteral(resourceName: "Walk"), viewControllerIdentifier: "FieldWalkVC")], [NavigationItem.init(title: "Svampe-bog", icon: #imageLiteral(resourceName: "Book"), viewControllerIdentifier: "MainVC"), NavigationItem.init(title: "Artsbestemmelse", icon: #imageLiteral(resourceName: "Camera"), viewControllerIdentifier: "RecognizeVC")]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(gradientView)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let trailingConstraint = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: .trailing, multiplier: 0.6, constant: 0.0)
        view.addConstraint(trailingConstraint)
        trailingConstraint.isActive = true
        
        
        userView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        userView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        userView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        userView.setNeedsLayout()
        userView.layoutIfNeeded()
        
        UserService.instance.getUserDetails { (appError, user) in
            if let user = user {
                DispatchQueue.main.async {
                    self.userView.configure(user: user)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstLoad {
            tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .top)
            firstLoad = false
        }
        super.viewWillAppear(animated)
    }
}

extension NavigationVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return navigationItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationItems[section].count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "navigationCell", for: indexPath) as! NavigationCell
                cell.configureCell(navigationItem: navigationItems[indexPath.section][indexPath.row])
                return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

                        return 50

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
                        let view = UIView()
                        view.backgroundColor = UIColor.clear
                        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc: UIViewController?
        
                let identifier = navigationItems[indexPath.section][indexPath.row].viewControllerIdentifier
                switch identifier {
                case "RecognizeVC":
                    vc = UINavigationController(rootViewController: RecognizeVC(isObservation: false))
                case "NewObservationVC":
                    vc = NewObservationVC()
                case "FieldWalkVC":
                    vc = FieldWalkVC()
                case "LoginVC":
                    vc = LoginVC()
                default:
                    vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: navigationItems[indexPath.section][indexPath.row].viewControllerIdentifier)
                }
            self.eLRevealViewController()?.pushNewViewController(viewController: vc!)
    }
}
