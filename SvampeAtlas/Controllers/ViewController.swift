//
//  ViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var tableView: MushroomTableView!
    @IBOutlet weak var categoryView: CategoryView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarWidthConstraint: NSLayoutConstraint!
    
    @IBAction func seachBarEntryChanged(_ sender: UISearchBar) {
        guard let text = sender.text, text != "" else {sender.setShowsCancelButton(false, animated: true); return}
        sender.setShowsCancelButton(true, animated: true)
    }
    
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
    private var hasBeenSetup = false
    private var previousContentOffset: CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        categoryView.delegate = self
        searchBar.searchBarDelegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.appWhite(), NSAttributedStringKey.font: UIFont.appTitle()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = UIColor.appPrimaryColour()
        setupView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !hasBeenSetup {
        categoryView.firstSelect()
            hasBeenSetup = true
        }
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupView() {
        searchBar.isHidden = true
        tableView.contentInset = UIEdgeInsets(top: searchBar.frame.size.height + 8, left: 0.0, bottom: 0.0, right: 0.0)
//        seachBar.barTintColor = UIColor.appPrimaryColour()
//        seachBar.showsScopeBar = true
//        seachBar.delegate = self
//        seachBar.placeholder = "Søg efter en art"
//        seachBar.tintColor = UIColor.appWhite()
//        if let textFieldInsideSearchBar = seachBar.value(forKey: "searchField") as? UITextField {
//            textFieldInsideSearchBar.textColor = UIColor.appWhite()
//            textFieldInsideSearchBar.font = UIFont.appPrimaryHightlighed()
//        }
        
        
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mushrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mushroomCell", for: indexPath) as? MushroomCell else {
            // Show error to user
            return UITableViewCell()
        }
        cell.configureCell(withMushroom: mushrooms[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "detailsVC") as? DetailsViewController else {return}
        detailsVC.mushroom = mushrooms[indexPath.row]
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

extension ViewController: CategoryViewDelegate {
    func newCategorySelected(category: Category) {
        tableView.categoryType = category
        mushrooms.removeAll()
        tableView.reloadData()
        switch category {
        case .offline:
            getOfflineMushrooms()
        default:
            getDanishMushrooms()
        }
    }
}

extension ViewController {
    private func getOfflineMushrooms() {
        
    }
    
    private func getFavoritesMushrooms() {
                tableView.reloadData()
    }
    
    private func getDanishMushrooms() {
        tableView.showLoader()
        DataService.instance.getMushrooms { (mushrooms) in
            DispatchQueue.main.async {
                self.searchBar.isHidden = false
                self.shouldExpandSearchBar()
                self.mushrooms = mushrooms
                self.tableView.reloadData()
            }
        }
    }
    
    private func handleFavoritingOfMushroom(mushroom: Mushroom) {
        
    }
}


extension ViewController: CustomSearchBarDelegate {
    func shouldCollapseSearchBar() {
        if searchBar.isExpanded {
        searchBarLeadingConstraint.isActive = false
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 58)
        searchBarWidthConstraint.isActive = true
        self.searchBar.collapsedProperties()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (succes) in
            
        }
        }
    }
    
    func shouldExpandSearchBar() {
        if !searchBar.isExpanded && !searchBar.isHidden {
        searchBarWidthConstraint.isActive = false
        searchBarLeadingConstraint.isActive = true
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.searchBar.expandedProperties()
        }) { (succes) in
            
        }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            shouldExpandSearchBar()
        } else {
            shouldCollapseSearchBar()
        }
    
//        if previousContentOffset != nil {
//            if scrollView.contentOffset.y <= -scrollView.contentInset.top {
//                setSeachbarHidden(false)
//            } else if previousContentOffset!.y > scrollView.contentOffset.y {
//                setSeachbarHidden(false)
//            } else {
//                setSeachbarHidden(true)
//            }
//        }
//        previousContentOffset = scrollView.contentOffset
    }
}
