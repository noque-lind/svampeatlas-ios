//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class MushroomVC: UIViewController {
    
    private enum Categories: String, CaseIterable {
        case favorites = "Mine favoritter"
        case species = "Svampearter"
    }
    
    private var gradientView: GradientView = {
       let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryView: CategoryView<Categories> = {
        let items = Categories.allCases.compactMap({Category<Categories>(type: $0, title: $0.rawValue)})
        var view = CategoryView<Categories>(categories: items, firstIndex: 1)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    private lazy var tableView: MushroomTableView = {
        let tableView = MushroomTableView(animating: true, automaticallyAdjustHeight: false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        
        tableView.isAtTop = { [unowned self] isAtTop in
            if isAtTop {
                self.searchBar.expand()
            } else {
                self.searchBar.collapse()
            }
        }
        
        tableView.didSelectItem = { [unowned self] mushroom in
            self.navigationController?.pushViewController(DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: self.session, takesSelection: nil)), animated: true)
        }
       
        tableView.didRequestAdditionalDataAtOffset = { (tableView, offset, max) in
            var currentItems = tableView.tableViewState.currentItems()
            DataService.instance.getMushrooms(offset: offset, completion: { (result) in
                switch result {
                case .Error(let error):
                    tableView.tableViewState = .Error(error, nil)
                case .Success(let mushrooms):
                    currentItems.append(contentsOf: mushrooms)
                    tableView.tableViewState = .Paging(items: currentItems, max: nil)
                }
            })
        }

        tableView.mushroomSwiped = { [unowned self] mushroom in
            if CoreDataHelper.mushroomAlreadyFavorited(mushroom: mushroom) {
                CoreDataHelper.deleteMushroom(mushroom: mushroom, completion: { [weak self] in
                    guard let selectedItemType = self?.categoryView.selectedItem.type, case Categories.favorites = selectedItemType else {
                        return
                    }

                    CoreDataHelper.fetchAllFavoritedMushrooms(completion: { [weak self] (result) in
                        switch result {
                        case .Success(let mushrooms):
                            self?.tableView.tableViewState = .Items(mushrooms)
                        case .Error(let error):
                            self?.tableView.tableViewState = .Error(error, nil)
                        }
                    })
                })
            } else {
                CoreDataHelper.saveMushroom(mushroom: mushroom) { (result) in
                    switch result {
                    case .Error(let error):
                        DispatchQueue.main.async {
                            let view = ELNotificationView(style: ELNotificationView.Style.error, attributes: ELNotificationView.Attributes(font: UIFont.appPrimaryHightlighed()), primaryText: error.errorTitle, secondaryText: error.errorDescription)
                            view.show(animationType: ELNotificationView.AnimationType.fromBottom)
                        }
                    case .Success(_):
                        DispatchQueue.main.async {
                            let view = ELNotificationView(style: ELNotificationView.Style.success, attributes: ELNotificationView.Attributes(font: UIFont.appPrimaryHightlighed()), primaryText: "Du har gjort \(mushroom.danishName ?? mushroom.fullName) til din favorit", secondaryText: "Du kan nu altid se svampen, også uden internet.")
                            view.show(animationType: ELNotificationView.AnimationType.fromBottom)
                        }
                    }
                }
            }
        }
        return tableView
    }()
    
    private lazy var searchBar: CustomSearchBar = {
       let view = CustomSearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarDelegate = self
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.isHidden = true
        return view
    }()
    
    private var defaultTableViewState: TableViewState<Mushroom>?
    private var session: Session?
    
    init(session: Session?) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("MushroomVC Deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.navigationController != nil) {
            print("Navigation controller not nil in MushroomVC")
        }
           self.navigationItem.setLeftBarButton(menuButton, animated: false)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.view.backgroundColor = nil
            self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
            self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.backgroundColor = nil
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            super.viewWillAppear(animated)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
        title = "Svampebog"
        
        view.insertSubview(gradientView, at: 0)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(categoryView)
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        categoryView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view.insertSubview(tableView, belowSubview: categoryView)
        tableView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(searchBar)
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: categoryView.bottomAnchor, constant: 8).isActive = true
        searchBar.leadingConstraint = searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        
        
//        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
//        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
//        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appTitle()]
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)

//        navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func showSearchBar() {
        DispatchQueue.main.async {
            self.tableView.contentInset = UIEdgeInsets(top: 58, left: 0.0, bottom: 0.0, right: 0.0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 58, left: 0.0, bottom: 0.0, right: 0.0)
            self.searchBar.isHidden = false
            self.searchBar.expand()
        }
    }
    
    private func hideSearchBar() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.contentInset = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
            self?.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
            self?.searchBar.isHidden = true
        }
    }
}



extension MushroomVC: CategoryViewDelegate {
    func categorySelected(category: Any) {
        guard let category = category as? Categories else {return}
        tableView.tableViewState = .Empty
        tableView.tableViewState = .Loading
        hideSearchBar()
        
        switch category {
        case .species:
            DataService.instance.getMushrooms(offset: 0) { [weak self] (result) in
                switch result {
                case .Error(let error):
                    self?.tableView.tableViewState = .Error(error, {
                        return
                    })
                case .Success(let mushrooms):
                    self?.showSearchBar()
                    self?.tableView.tableViewState = .Paging(items: mushrooms, max: nil)
                }
            }
        case .favorites:
            CoreDataHelper.fetchAllFavoritedMushrooms { [weak self] (result) in
                switch result {
                case .Success(let mushrooms):
                        self?.tableView.tableViewState = .Items(mushrooms)
                case .Error(let error):
                    self?.tableView.tableViewState = .Error(error, nil)
                }
            }
        }
    }
}


extension MushroomVC: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        defaultTableViewState = tableView.tableViewState
        tableView.tableViewState = .Loading
        
        DataService.instance.getMushroomsThatFitSearch(searchString: entry) { [weak self] (result) in
            switch result {
            case .Success(let mushrooms):
                self?.tableView.tableViewState = TableViewState.Items(mushrooms)
            case .Error(let appError):
                self?.tableView.tableViewState = TableViewState.Error(appError, nil)
            }
        }
    }

    func clearedSearchEntry() {
        if let defaultTableViewState = defaultTableViewState {
            tableView.tableViewState = defaultTableViewState
        }
    }
}

