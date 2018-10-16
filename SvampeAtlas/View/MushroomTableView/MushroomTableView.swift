//
//  MushroomTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol MushroomDataViewDelegate: NavigationDelegate {
    func showSearchBar(_ shouldShow: Bool)
    func expandSearchBar()
    func collapseSearchBar()
}

class MushroomDataView: UIView {
    
    private lazy var tableView: MushroomTableView = {
        let tableView = MushroomTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MushroomCell.self, forCellReuseIdentifier: "mushroomCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 58, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var mushroomBackgroundView: MushroomDataBackgroundView? {
        didSet {
            guard let mushroomBackgroundView = mushroomBackgroundView else {return}
            addSubview(mushroomBackgroundView)
            mushroomBackgroundView.delegate = self.delegate
            mushroomBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            mushroomBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            mushroomBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            mushroomBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    private var category: Category!
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private var mushrooms = [Mushroom]() {
        didSet {
            if mushrooms.count == 0 {
                tableView.alwaysBounceVertical = false
                delegate?.showSearchBar(false)
            } else {
                tableView.alwaysBounceVertical = true
                delegate?.showSearchBar(true)
                delegate?.expandSearchBar()
            }
            tableView.reloadData()
        }
    }
    
    var filteredMushrooms: [Mushroom]? {
        didSet {
            if oldValue == nil && filteredMushrooms == nil {
                return
            } else {
                tableView.reloadData()
            }
        }
    }
    
    weak var delegate: MushroomDataViewDelegate? = nil
    private var previousContentOffset: CGPoint?
    
    
    func categorySelected(category: Category) {
        self.category = category
        mushroomBackgroundView?.removeFromSuperview()
        mushroomBackgroundView = nil
        mushrooms.removeAll()
    
        switch category {
        case .mushrooms:
            tableView.showLoader()
            DataService.instance.getMushrooms(offset: 0) { (appError, mushrooms)  in
                DispatchQueue.main.async {
                    guard appError == nil, let mushrooms = mushrooms else {
                        self.delegate?.presentVC(UIAlertController(title: appError!.title, message: appError!.message))
                        self.tableView.backgroundView = nil
                        return
                    }
                    
                    if self.category == .mushrooms {
                        self.mushrooms = mushrooms
                    }
                }
            }
       
        case .favorites:
            CoreDataHelper.fetchAll { (cdMushrooms) in
                if cdMushrooms.count == 0 {
                    mushroomBackgroundView = FavoritesBackground()
                } else {
                    DispatchQueue.main.async {
                        if self.category == .favorites {
                            self.mushrooms = cdMushrooms
                        }
                    }
                }
            }
           
        case .nearby:
            mushroomBackgroundView = LocationBackground()
        default:
            return
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            delegate?.expandSearchBar()
        } else {
            delegate?.collapseSearchBar()
        }
    }
    
    
    private func handleFavoritingOfMushroom(mushroom: Mushroom) {
        if category == .favorites {
            CoreDataHelper.deleteMushroom(mushroom: mushroom) {
                print("Successfully deleted object")
            }
        } else {
            CoreDataHelper.saveMushroom(mushroom: mushroom) {
                print("Succesfully saved object")
            }
        }
    }
    
}

extension MushroomDataView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMushrooms = filteredMushrooms {
            return filteredMushrooms.count
        } else {
            return mushrooms.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mushroomCell", for: indexPath) as? MushroomCell else {
            fatalError()
        }
        
        if let filteredMushrooms = filteredMushrooms {
            cell.configureCell(mushroom: filteredMushrooms[indexPath.row])
        } else {
            cell.configureCell(mushroom: mushrooms[indexPath.row])
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC: DetailsViewController!
        
        if let filteredMushrooms = filteredMushrooms {
            detailsVC = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: filteredMushrooms[indexPath.row]))
        } else {
            detailsVC = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushrooms[indexPath.row]))
        }
        
        delegate?.pushVC(detailsVC)
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

class MushroomDataBackgroundView: UIView {
    weak var delegate: NavigationDelegate? = nil
}

class MushroomTableView: UITableView {
    override func reloadData() {
        super.reloadData()
        if self.visibleCells.count > 0 {
            self.backgroundView = nil
            var delayCounter = 0.0
            for cell in self.visibleCells {
                cell.contentView.alpha = 0
                UIView.animate(withDuration: 0.2, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                    cell.contentView.transform = CGAffineTransform.identity
                    cell.contentView.alpha = 1
                }, completion: nil)
                delayCounter = delayCounter + 0.10
            }
        }
    }
    
    func showLoader() {
        self.backgroundView = UIView(frame: self.frame)
        self.backgroundView?.controlActivityIndicator(wantRunning: true)
    }
}
