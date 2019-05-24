//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
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
        
            let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
                self.mushroomSwiped?(mushroom)
                completion(true)
            }
        
        if CoreDataHelper.mushroomAlreadyFavorited(mushroom: mushroom) {
            action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            action.image = #imageLiteral(resourceName: "Icon_DeFavorite")
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            action.image = #imageLiteral(resourceName: "Favorite")
            return UISwipeActionsConfiguration(actions: [action])
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            isAtTop?(true)
        } else {
            isAtTop?(false)
        }
    }
}


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
        
        tableView.isAtTop = { [unowned self] isAtTop in
            if isAtTop {
                self.searchBar.expand()
            } else {
                self.searchBar.collapse()
            }
        }
        
        tableView.didSelectItem = { [unowned self] mushroom in
            self.navigationController?.pushViewController(DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, takesSelection: nil)), animated: true)
        }
        
        tableView.mushroomSwiped = { [unowned self] mushroom in
            if CoreDataHelper.mushroomAlreadyFavorited(mushroom: mushroom) {
                CoreDataHelper.deleteMushroom(mushroom: mushroom, completion: {
                    guard case Categories.favorites = self.categoryView.selectedItem!.type else {
                        return
                    }

                    CoreDataHelper.fetchAllFavoritedMushrooms(completion: { (result) in
                        switch result {
                        case .Success(let mushrooms):
                            self.tableView.tableViewState = .Items(mushrooms)
                        case .Error(let error):
                            self.tableView.tableViewState = .Error(error, nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isTranslucent = false
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        title = "Svampebog"
        
        view.insertSubview(gradientView, at: 0)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
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
        
        
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appHeader()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
        DispatchQueue.main.async {
            self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
            self.searchBar.isHidden = true
        }
    }
}

extension MushroomVC {
    
        /*
     
        
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let action = UITableViewRowAction(style: .normal, title: "Gem som favorit") { (action, indexPath) in
            }
            action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
            return [action]
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
        }
 */
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
//                    self.tableViewState = TableViewState.Items(mushrooms)
                case .Error(let error):
                    self?.tableView.tableViewState = .Error(error, nil)
//                    self.tableViewState = TableViewState.Error(error, nil)
                }
            }
        }
    }
}


extension MushroomVC: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        defaultTableViewState = tableView.tableViewState
        tableView.tableViewState = .Loading
        
        DataService.instance.getMushroomsThatFitSearch(searchString: entry) { (result) in
            switch result {
            case .Success(let mushrooms):
                self.tableView.tableViewState = TableViewState.Items(mushrooms)
            case .Error(let appError):
                self.tableView.tableViewState = TableViewState.Error(appError, nil)
            }
        }
    }

    func clearedSearchEntry() {
        if let defaultTableViewState = defaultTableViewState {
            tableView.tableViewState = defaultTableViewState
        }
    }
}

