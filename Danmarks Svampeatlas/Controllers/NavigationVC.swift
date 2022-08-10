//
//  SideMenuController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 27/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.

import UIKit

class NavigationVC: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(NavigationCell.self, forCellReuseIdentifier: String(describing: NavigationCell.self))
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = userView
        tableView.tableFooterView = footerView
        return tableView
    }()
    
    private lazy var footerView: UIView = {
       let view = UIView()
        view.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 100)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = []
//        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
//        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label: UILabel = {
           let label = UILabel()
            label.font = UIFont.appPrimary(customSize: 12)
            label.textColor = UIColor.appWhite().withAlphaComponent(0.5)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                label.text = "Version: \(version) Build \(build)"
            }
            
            return label
        }()
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var userView: UserView = {
        let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = []
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return view
    }()
    
    private var firstLoad = true
    
    var session: Session? {
        didSet {
            firstLoad = true
        }
    }
    
    private var navigationItems: [[NavigationItem]] {
        if session != nil {
            return [[.myPageVC, .notebook, .newObservationVC], [.nearbyVC, .mushroomsVC, .cameraVC], [.about, .settings, .facebook]]
        } else {
            return [[.loginVC], [.nearbyVC, .mushroomsVC, .cameraVC], [.about, .settings, .facebook]]
        }
    }
    
    init(session: Session?) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if firstLoad {
            if session?.user != nil {
                tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            } else {
                 tableView.selectRow(at: IndexPath(row: 1, section: 1), animated: false, scrollPosition: .top)
            }
            firstLoad = false
        }
        
        if let user = session?.user {
            userView.configure(user: user)
        } else {
            userView.configureAsGuest()
        }
        
        if self.tableView.numberOfRows(inSection: 0) != navigationItems[0].count {
            UIView.performWithoutAnimation {
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
            }
        }
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        
        let gradientView: GradientView = {
            let view = GradientView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
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
    }
}

extension NavigationVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return navigationItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationItems[section].count
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return navigationItems[indexPath.section][indexPath.row].isEnabled
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NavigationCell.self), for: indexPath) as! NavigationCell
        cell.configureCell(navigationItem: navigationItems[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc: UIViewController
        var overrideTypeCheckIgnore: Bool = false
        
        switch navigationItems[indexPath.section][indexPath.row] {
        case .loginVC:
            vc =  LoginVC()
        case .mushroomsVC:
            vc = MushroomVC(session: session)
        case .myPageVC:
            guard let session = session else {return}
            vc = MyPageVC(session: session)
        case .nearbyVC:
            vc = NearbyVC(session: session)
        case .newObservationVC:
            overrideTypeCheckIgnore = true
            guard let session = session else {return}
            vc = CameraVC(cameraVCUsage: .newObservationRecord(session: session))
        case .cameraVC:
            overrideTypeCheckIgnore = true
            vc = CameraVC(cameraVCUsage: .mlPredict(session: session))
        case .facebook:
            UIApplication.tryURL(urls: ["fb://profile/37769823521", "https://www.facebook.com/groups/svampeatlas/"])
            return
        case .about:
            vc = AboutVC()
        case .settings:
            vc = SettingsVC()
        case .notebook:
            guard let session = session else {return}
            vc = NotesVC(session: session)
        }
        
        self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: vc), overrideTypeCheckIgnore: overrideTypeCheckIgnore)
    }
}
