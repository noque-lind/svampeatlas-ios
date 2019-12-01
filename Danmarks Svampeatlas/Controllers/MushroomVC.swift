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
        
        view.categorySelected = { [unowned self, unowned tableView] category in
            tableView.setSections(sections: [.init(title: nil, state: .loading)])
            self.hideSearchBar()
            
            switch category {
            case .species:
                let limit = 35
                DataService.instance.getMushrooms(searchString: nil, limit: limit) { [weak self] (result) in
                    guard category == self?.categoryView.selectedItem.type  else {return}
                    switch result {
                    case .Error(let error):
                        self?.tableView.setSections(sections: [.init(title: nil, state: .error(error: error))])
                    case .Success(let mushrooms):
                        self?.showSearchBar()
                        
                        var items = mushrooms.compactMap({MushroomTableView.Item.mushroom($0)})
                        
                        if mushrooms.count == limit {
                            items.append(.loadMore(offset: mushrooms.count))
                        }
                        
                        self?.tableView.setSections(sections: [.init(title: nil, state: .items(items: items))])
                    }
                }
            case .favorites:
                CoreDataHelper.fetchAllFavoritedMushrooms { [weak tableView] (result) in
                    switch result {
                    case .Success(let mushrooms):
                        tableView?.setSections(sections: [.init(title: nil, state: .items(items: mushrooms.compactMap({MushroomTableView.Item.mushroom($0)})))])
                    case .Error(let error):
                        tableView?.setSections(sections: [.init(title: nil, state: .error(error: error))])
                    }
                }
            }
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var tableView: MushroomTableView = {
        let tableView = MushroomTableView()
        
        tableView.didSelectItem = { [unowned self, unowned tableView] item, indexPath in
            switch item {
            case .loadMore(offset: let offset):
                let section = Section<MushroomTableView.Item>.init(title: nil, state: .loading)
                
                tableView.performUpdates(updates: { (updater) in
                    updater.addSection(section: section)
                    updater.removeItem(indexPath: indexPath)
                }) {
                    let limit = 35
                    DataService.instance.getMushrooms(searchString: nil, limit: limit, offset: offset, completion: { (result) in
                        switch result {
                        case .Error(let error):
                            section.setState(state: .error(error: error))
                        case .Success(let mushrooms):
                            
                            var items = mushrooms.compactMap({MushroomTableView.Item.mushroom($0)})
                            
                            if mushrooms.count == limit {
                                items.append(.loadMore(offset: offset + mushrooms.count))
                            }
                            
                            section.setState(state: .items(items: items))
                        }
                        
                        tableView.performUpdates(updates: { (updater) in
                            updater.updateSection(section: section)
                        })
                    })
                }
                
            case .mushroom(let mushroom):
                self.navigationController?.pushViewController(DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: self.session, takesSelection: nil)), animated: true)
                
            }
        }
        
        tableView.isAtTop = { [unowned searchBar] isAtTop in
            if isAtTop {
                searchBar.expand()
            } else {
                searchBar.collapse()
            }
        }
        
        tableView.mushroomSwiped = { [unowned self] mushroom, indexPath in
            if CoreDataHelper.mushroomAlreadyFavorited(mushroom: mushroom) {
                CoreDataHelper.deleteMushroom(mushroom: mushroom, completion: { [weak self] in
                    guard let selectedItemType = self?.categoryView.selectedItem.type, case Categories.favorites = selectedItemType else {
                        return
                    }
                    
                    tableView.performUpdates(updates: { (updater) in
                        updater.removeItem(indexPath: indexPath, animation: .left)
                    }, completion: nil)
                })
            } else {
                CoreDataHelper.saveMushroom(mushroom: mushroom) { (result) in
                    DispatchQueue.main.async {
                    switch result {
                    case .Error(let error):
                            ELNotificationView.appNotification(style: .error(actions: nil), primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .bottom)
                                .show(animationType: .fromBottom)
                    case .Success(_):
                        ELNotificationView.appNotification(style: .success, primaryText: "\(mushroom.danishName ?? mushroom.fullName) er nu markeret som favorit", secondaryText: "Du har hurtig adgang til at se svampen og dens billeder, også uden internet - under mine favoritter.", location: .bottom)
                            .show(animationType: .fromBottom)
                    }
                    }
                }
            }
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        title = "Svampebog"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
    
        view.backgroundColor = UIColor.appPrimaryColour()
        
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
    }
    
    private func showSearchBar() {
        DispatchQueue.main.async {
            self.tableView.contentInset = UIEdgeInsets(top: 58, left: 0.0, bottom: 0.0, right: 0.0)
            self.searchBar.isHidden = false
            self.searchBar.expand()
        }
    }
    
    private func hideSearchBar() {
        DispatchQueue.main.async {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0)
            self.searchBar.isHidden = true
            self.searchBar.text = nil
        }
    }
}

extension MushroomVC: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
                DataService.instance.getMushrooms(searchString: entry) { [weak tableView] (result) in
                    switch result {
                    case .Success(let mushrooms):
                        tableView?.setSections(sections: [.init(title: nil, state: .items(items: mushrooms.compactMap({MushroomTableView.Item.mushroom($0)})))])
                    case .Error(let appError):
                        tableView?.setSections(sections: [.init(title: nil, state: .error(error: appError))])
                    }
                }
    }
    
    func clearedSearchEntry() {
        categoryView.selectCategory(category: Categories.species, force: true)
    }
}

