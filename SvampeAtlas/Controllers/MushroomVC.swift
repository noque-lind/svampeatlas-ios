//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomVC: UIViewController {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var tableView: MushroomTableView!
    @IBOutlet weak var categoryView: CategoryView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarWidthConstraint: NSLayoutConstraint!
    
    var mushrooms = [Mushroom]() {
        didSet {
            if mushrooms.count == 0 {
                searchBar.alpha = 0
                tableView.alwaysBounceVertical = false
            } else {
                tableView.alwaysBounceVertical = true
                searchBar.alpha = 1
            }
        }
    }
    
    var filteredMushrooms: [Mushroom]?
    private var previousContentOffset: CGPoint?
    
    
private var hasBeenSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mushroomBackgroundDelegate = self
        categoryView.delegate = self
        searchBar.searchBarDelegate = self
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupView() {
        searchBar.isHidden = true
        tableView.contentInset = UIEdgeInsets(top: searchBar.frame.size.height + 8, left: 0.0, bottom: 0.0, right: 0.0)
        categoryView.firstSelect()
        setupNavigationController()
    }
    
    
    private func setupNavigationController() {
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.appWhite(), NSAttributedStringKey.font: UIFont.appHeader()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension MushroomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMushrooms = filteredMushrooms {
            return filteredMushrooms.count
        } else {
        return mushrooms.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mushroomCell", for: indexPath) as? MushroomCell else {
            fatalError("Could not deque mushroomCell")
        }
        if let filteredMushrooms = filteredMushrooms {
            cell.configureCell(withMushroom: filteredMushrooms[indexPath.row])
        } else {
        cell.configureCell(withMushroom: mushrooms[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = DetailsViewController(mushroom: mushrooms[indexPath.row])
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.pushViewController(detailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.handleFavoritingOfMushroom(mushroom: self.mushrooms[indexPath.row])
            completion(true)
            
        }
        action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        action.image = #imageLiteral(resourceName: "Favorite")
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .normal, title: "Gem som favorit") { (action, indexPath) in
            
        }
        action.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        return [action]
    }
}

extension MushroomVC {
    private func handleFavoritingOfMushroom(mushroom: Mushroom) {
        
    }
}

extension MushroomVC: CategoryViewDelegate {
    func newCategorySelected(category: Category) {
        tableView.categoryType = category
        mushrooms.removeAll()
        tableView.reloadData()
        getMushrooms(categoryType: category)
    }

    private func getMushrooms(categoryType category: Category) {
        switch category {
        case .local:
            DataService.instance.getMushrooms { (mushrooms) in
                DispatchQueue.main.async {
                }
            }
        case .offline:
            break
            
        case .favorites:
            break
        default:
            tableView.showLoader()
            DataService.instance.getMushrooms { (mushrooms) in
                DispatchQueue.main.async {
                    self.prepareSearchBar()
                    self.mushrooms = mushrooms
                    self.tableView.reloadData()
                }
        }
    }
    }
    

    private func getDanishMushrooms() {
        tableView.showLoader()
        DataService.instance.getMushrooms { (mushrooms) in
            DispatchQueue.main.async {
                self.prepareSearchBar()
                
                self.tableView.reloadData()
            }
        }
    }
}


extension MushroomVC: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        filteredMushrooms = []
        previousContentOffset = tableView.contentOffset
        tableView.reloadData()
    }
    
    func clearedSearchEntry() {
        filteredMushrooms = nil
        tableView.reloadData()
        
        guard let previousContentOffset = previousContentOffset else {return}
        self.tableView.setContentOffset(previousContentOffset, animated: false)
    }
    
    private func prepareSearchBar() {
        searchBar.isHidden = false
        searchBar.expand()
    }
    
    
    func shouldExpandSearchBar(animationDuration: TimeInterval) {
            searchBarWidthConstraint.isActive = false
            searchBarLeadingConstraint.isActive = true
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) { (succes) in
                
            }
    }
    
    func shouldCollapseSearchBar(animationDuration: TimeInterval) {
            searchBarLeadingConstraint.isActive = false
            searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 58)
            searchBarWidthConstraint.isActive = true
        
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (succes) in
                
            }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            searchBar.expand()
        } else {
            searchBar.collapse()
        }
    }
}

extension MushroomVC: MushroomBackgroundDelegate {
    func showVC(vc: UIViewController) {
        self.navigationController!.pushViewController(vc, animated: true)
    }
}
