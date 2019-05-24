//
//  ELGenericTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 16/11/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CustomTableView: AppTableView {
    
    


    
    
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.point(inside: point, with: event) {
//            return self
//        } else {
//            return nil
//        }
//    }
    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer is UITapGestureRecognizer {
//            return false
//        } else {
//            return true
//        }
//    }
}


protocol GenericTableViewDelegate: NavigationDelegate {
    
    associatedtype Item
    
    func tableView(_ tableView: UITableView, didRequestAdditionalDataAtOffset offset: Int)
    func tableView(_ tableView: UITableView, didSelectItem item: Item)
}

extension GenericTableViewDelegate {
    func tableView(_ tableView: UITableView, didRequestAdditionalDataAtOffset offset: Int) {}
    func tableView(_ tableView: UITableView, didSelectItem item: Item) {}
}

class GenericTableView<T>: UIView, UITableViewDataSource, UITableViewDelegate {
    
    lazy var tableView: CustomTableView = {
        let tableView = CustomTableView(animating: self.animating, frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.appSecondaryColour()
        tableView.alwaysBounceVertical = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.panGestureRecognizer.isEnabled = false
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = false
        tableView.register(ReloadCell.self, forCellReuseIdentifier: "reloadCell")
        return tableView
    }()
    
    private var heightConstraint = NSLayoutConstraint()
    private var automaticallyAdjustHeight: Bool
    private var animating: Bool
//    weak var delegate: Delegate?
    
    var didRequestAdditionalDataAtOffset: ((_ tableView: GenericTableView<T>, _ offset: Int, _ max: Int?) -> ())?
    var didSelectItem: ((_ item: T) -> ())?
    
    var tableViewState: TableViewState<T> = TableViewState.None {
        didSet {
            switch tableViewState {
            case .Empty:
                tableView.reloadData()
            case .Loading:
                self.tableView.showLoader()
                return
            case .Paging:
                break
            case .Items:
                break
            case .Error(let error, let handler):
                self.tableView.showError(error, handler: handler)
            case .None:
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init(animating: Bool = false, automaticallyAdjustHeight: Bool = true) {
        self.animating = animating
        self.automaticallyAdjustHeight = automaticallyAdjustHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        backgroundColor = UIColor.clear
        clipsToBounds = false
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if automaticallyAdjustHeight {
            heightConstraint = heightAnchor.constraint(equalToConstant: 120)
            heightConstraint.isActive = true
            tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: [], context: nil)
        }
    }
    
    func didRequestAdditionalDataAtOffset(_ offset: Int, max: Int?) {
        didRequestAdditionalDataAtOffset?(self, offset, max)
    }
    
    func didSelectItem(item: T) {
        didSelectItem?(item)
    }
    
    func register(_ cellClass: AnyClass, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard automaticallyAdjustHeight == true else {return}
        switch tableViewState {
        case .Items, .Paging:
            if keyPath == #keyPath(UITableView.contentSize) {
                heightConstraint.isActive = false
                heightConstraint.constant = tableView.contentSize.height
                heightConstraint.isActive = true
            }
        default:
                heightConstraint.isActive = false
                heightConstraint.constant = 120
                heightConstraint.isActive = true
        }
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewState {
        case .Items:
            return tableViewState.itemsCount()
        case .Paging:
            return tableViewState.itemsCount() + 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ReloadCell {
            if case .Paging(_, let max) = tableViewState {
                didRequestAdditionalDataAtOffset(indexPath.row, max: max)
            }
        } else {
            guard let item = tableViewState.value(row: indexPath.row) else {return}
            didSelectItem?(item)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}



