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




class TestTableView<T>: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets.zero
        view.separatorColor = UIColor.appSecondaryColour()
        view.alwaysBounceVertical = false
        view.contentInsetAdjustmentBehavior = .never
        view.panGestureRecognizer.isEnabled = false
        view.tableFooterView = UIView()
        view.delegate = self
        view.dataSource = self
        view.clipsToBounds = true
        view.register(ErrorCell.self, forCellReuseIdentifier: ErrorCell.identifier)
        view.register(LoaderCell.self, forCellReuseIdentifier: LoaderCell.identifier)
        return view
    }()
    
    var sections = [Section<T>]()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        clipsToBounds = false
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func setSections(sections: [Section<T>]) {
        self.sections = sections
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func addSection(section: Section<T>) {
        sections.append(section)
        
        DispatchQueue.main.async {
            self.tableView.insertSections(IndexSet(integer: self.sections.endIndex - 1), with: .bottom)
        }
    }
    
    func removeItem(item: T, indexPath: IndexPath) {
        sections[indexPath.section].removeItemAt(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func register(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func cellForItem(_ item: T, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func heightForItem(_ item: T) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func didSelectItem(_ item: T, indexPath: IndexPath) {}
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count()
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].state {
        case .error(error: let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: ErrorCell.identifier, for: indexPath) as! ErrorCell
            cell.configure(error: error)
            return cell
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: LoaderCell.identifier, for: indexPath)
        case .items(items: let items):
            guard let item = items[safe: indexPath.row] else {return UITableViewCell()}
            let cell = cellForItem(item, tableView: tableView, indexPath: indexPath)
            return cell
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].state {
        case .error:
            if sections.count == 1 {
                return tableView.frame.height
            } else {
                return 350
            }
        case .loading:
            if sections.count == 1 {
                return tableView.frame.height
            } else {
                return 200
            }
        case .items(items: let items):
            return heightForItem(items[indexPath.row])
        }
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = sections[indexPath.section].itemAt(index: indexPath.row) else {return}
        didSelectItem(item, indexPath: indexPath)
    }
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
    //    weak var delegate: GenericTableViewDelegate?
    
    /**
     Assign a closure to this variable that takes the following parameters:
     
     - Parameters:
     - genericTableView<T>: The tableview it is called from.
     - int: The current tableView offset
     - int: The maximum number of items in the model.
     */
    var didRequestAdditionalDataAtOffset: ((_ tableView: GenericTableView<T>, _ offset: Int, _ max: Int?) -> ())?
    var didSelectItem: ((_ item: T) -> ())?
    
    var tableViewState: TableViewState<T> = TableViewState.None {
        didSet {
            switch tableViewState {
            case .Empty:
                tableView.reloadData()
            case .Loading:
                self.tableView.showLoader()
            case .Paging:
                break
            case .Items:
                break
            case .Error(let error, let handler):
                self.tableView.showError(error, handler: handler)
            case .None:
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
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
        return UITableView.automaticDimension
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



