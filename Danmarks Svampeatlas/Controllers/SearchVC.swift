//
//  SearchController.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 22/06/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

fileprivate class HostTableView: GenericTableView<Host> {
    
     var isAtTop: ((Bool) -> ())?
    
    override func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        super.setupView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let selectionView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.appThird()
            return view
        }()
        cell.selectedBackgroundView = selectionView
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.appWhite()
        cell.textLabel?.font = UIFont.appPrimaryHightlighed()
        
        if let host = tableViewState.value(row: indexPath.row) {
            cell.textLabel?.text = "- \(host.dkName?.capitalizeFirst() ?? "") (\(host.latinName ?? ""))"
        }
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            isAtTop?(true)
        } else {
            isAtTop?(false)
        }
    }
}

class SearchVC: UIViewController {

    private lazy var searchBar: SearchBar = {
       let view = SearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarDelegate = self
        view.isHidden = false
        view.alpha = 1.0
        view.configurePlaceholder(NSLocalizedString("searchVC_searchBar_placeholder", comment: ""))
        return view
    }()
    
    private lazy var tableView: HostTableView = {
       let tableView = HostTableView(animating: false, automaticallyAdjustHeight: false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.didSelectItem = { [unowned self] item in
            let host = Host(id: item.id, dkName: item.dkName, latinName: item.latinName, probability: item.probability, userFound: true)
            CoreDataHelper.saveHost(userFound: true, hosts: [host])
            self.didSelectItem?(item)
            self.dismiss(animated: true, completion: nil)
        }
        
        tableView.isAtTop = { [unowned self] isAtTop in
            if isAtTop {
                self.searchBar.expand()
            } else {
                self.searchBar.collapse()
            }
        }
        
        return tableView
    }()
    
   private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("searchVC_cancelButton", comment: ""), for: [])
        button.titleLabel?.font = UIFont.appPrimaryHightlighed()
        button.backgroundColor = UIColor.appSecondaryColour()
        button.setTitleColor(UIColor.appThird(), for: [])
        button.layer.cornerRadius = 10
        button.layer.shadowOpacity = 0.4
        button.addTarget(self, action: #selector(dismissview), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(searchBar)
        searchBar.leadingConstraint = searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        searchBar.leadingConstraint.isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        return view
    }()
    
    var didSelectItem: ((Host) -> ())?
    
    override func viewWillLayoutSubviews() {
        tableView.tableView.contentInset = UIEdgeInsets(top: searchBar.frame.height + (8 * 2), left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        tableView.tableView.scrollIndicatorInsets = UIEdgeInsets(top: searchBar.frame.height + (8 * 2), left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @objc private func dismissview() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissview))
//        view.addGestureRecognizer(tap)
        
        view.addSubview(cancelButton)
        cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(contentView)
        contentView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
        searchBar.expand()
       
    }
}

extension SearchVC: CustomSearchBarDelegate {
    func clearedSearchEntry() {
        tableView.tableViewState = .Empty
    }
    
    func newSearchEntry(entry: String) {
        DataService.instance.downloadHosts(shouldSave: false, searchString: entry) { [weak tableView] (result) in
            switch result {
            case .failure(let error):
                tableView?.tableViewState = .Error(error, nil)
            case .success(let hosts):
                tableView?.tableViewState = .Items(hosts)
            }
        }
    }
}
