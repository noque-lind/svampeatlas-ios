//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomVC: UIViewController {
    
    @IBOutlet weak var categoryView: CategoryView!
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(menuButtonPressed))
        return button
    }()
    
    private lazy var mushroomDataView: MushroomDataView = {
       let view = MushroomDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var searchBar: CustomSearchBar = {
       let view = CustomSearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightConstraint = view.heightAnchor.constraint(equalToConstant: 50)
        view.heightConstraint.isActive = true
        view.searchBarDelegate = self
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.isHidden = true
        return view
    }()
    
    private var hasAppeared = false

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryView.delegate = self
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if !hasAppeared {
            categoryView.firstSelect(index: 0)
            hasAppeared = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupView() {
        view.addSubview(mushroomDataView)
        mushroomDataView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        mushroomDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mushroomDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mushroomDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(searchBar)
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: categoryView.bottomAnchor, constant: 8).isActive = true
        searchBar.leadingConstraint = searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        searchBar.widthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 58)
        
        setupNavigationController()
    }
    
    
    private func setupNavigationController() {
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appHeader()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc private func menuButtonPressed() {
        self.eLRevealViewController()?.toggleSideMenu()
    }
}

extension MushroomVC: CategoryViewDelegate {
    func newCategorySelected(category: Category) {
        mushroomDataView.categorySelected(category: category)
    }
}


extension MushroomVC: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        DataService.instance.getMushroomsThatFitSearch(searchString: entry) { (appError, mushrooms) in
            self.mushroomDataView.filteredMushrooms = mushrooms
        }
    }

    func clearedSearchEntry() {
        mushroomDataView.filteredMushrooms = nil
//        filteredMushrooms = nil
//        tableView.reloadData()

//        guard let previousContentOffset = previousContentOffset else {return}
//        self.tableView.setContentOffset(previousContentOffset, animated: false)
    }
}

extension MushroomVC: MushroomDataViewDelegate {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showSearchBar(_ shouldShow: Bool) {
        searchBar.isHidden = shouldShow ? false: true
    }
    
    func expandSearchBar() {
        searchBar.expand()
    }
    
    func collapseSearchBar() {
        searchBar.collapse()
    }
}

