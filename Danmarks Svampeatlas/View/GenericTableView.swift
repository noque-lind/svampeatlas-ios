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

protocol ELTableViewUpdater {
    
    associatedtype T
    
    func addSection(section: Section<T>)
    func removeItem(indexPath: IndexPath)
    func updateSection(section: Section<T>)
}

class ELTableView<T>: UIView, UITableViewDataSource, UITableViewDelegate {
        
    class Updater {
        
        private var superclass: ELTableView
        
        init(superclass: ELTableView) {
            self.superclass = superclass
        }
        
        deinit {
            debugPrint("Updater deinit")
        }
        
        func addSection(section: Section<T>) {
            superclass.sections.append(section)
            superclass.tableView.insertSections(IndexSet(integer: superclass.sections.endIndex - 1), with: .bottom)
        }
        
        func removeItem(indexPath: IndexPath, animation: UITableView.RowAnimation = .none) {
            superclass.sections[indexPath.section].removeItemAt(index: indexPath.row)
            superclass.tableView.deleteRows(at: [indexPath], with: animation)
        }
        
        func updateSection(section: Section<T>?) {
            guard let section = section, let index = superclass.sections.index(of: section) else {return}
            superclass.tableView.reloadSections(IndexSet(integer: index), with: .automatic)
        }
        
        func scrollToTop(animated: Bool) {
            superclass.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: animated)
        }
    }
    
    private lazy var tableView: AnimatingTableView = {
        let view = AnimatingTableView(animating: true)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.separatorStyle = self.separatorStyle
        view.separatorInset = UIEdgeInsets.zero
        view.separatorColor = UIColor.appSecondaryColour()
        view.alwaysBounceVertical = false
        view.contentInsetAdjustmentBehavior = .never
        view.panGestureRecognizer.isEnabled = false
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.clipsToBounds = true
        view.register(ErrorCell.self, forCellReuseIdentifier: ErrorCell.identifier)
        view.register(LoaderCell.self, forCellReuseIdentifier: LoaderCell.identifier)
        view.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        return view
    }()
    
    override var tintColor: UIColor! {
        didSet {
            tableView.tintColor = tintColor
        }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) {
        didSet {
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }
    }
    
    var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    
    var scrollView: UIScrollView {
        get {
            return tableView
        }
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer {
        get {
            return tableView.panGestureRecognizer
        }
    }
    
    
    public private(set) var sections = [Section<T>]()
    var didSelectItem: ((T, IndexPath) -> ())?
    
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
    
 /// Remember to never reference anything else than the updater class within the update block.
    func performUpdates(updates: @escaping (Updater) -> (), completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates({
                updates(Updater(superclass: self))
            }) { (_) in
                completion?()
            }
        }
    }
    
    func setSections(sections: [Section<T>]) {
        DispatchQueue.main.async {
            self.sections = sections
            self.tableView.reloadData()
            
            if sections.first != nil && sections.first?.count() != 0 {
                self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
            }
        }
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
    
    func didSelectItem(_ item: T, indexPath: IndexPath) {
        didSelectItem?(item, indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title != nil ? UITableView.automaticDimension: 0.0
    }
    
    func scrollToTop(animated: Bool) {
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: animated)
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sections[section].title else {return nil}
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as! SectionHeaderView
        headerView.configure(text: title)
        return headerView
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count()
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].state {
        case .error(error: let error, let handler):
            let cell = tableView.dequeueReusableCell(withIdentifier: ErrorCell.identifier, for: indexPath) as! ErrorCell
            cell.configure(error: error, handler: handler)
            return cell
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: LoaderCell.identifier, for: indexPath)
        case .items(items: let items):
            guard let item = items[safe: indexPath.row] else {return UITableViewCell()}
            let cell = cellForItem(item, tableView: tableView, indexPath: indexPath)
            return cell
        case .empty: return UITableViewCell()
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].state {
        case .empty:
            return 0
        case .error:
            if sections.count == 1 {
                return tableView.frame.height
            } else {
                return 350
            }
        case .loading:
            if sections.count == 1 {
                return tableView.frame.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom
            } else {
                return LoaderCell.height
            }
        case .items(items: let items):
            if indexPath.row < items.count {
                return heightForItem(items[indexPath.row])
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? LoaderCell {
            cell.show()
        }
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = sections[indexPath.section].itemAt(index: indexPath.row) else {return}
        didSelectItem(item, indexPath: indexPath)
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

    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .never {
        didSet {
            tableView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        }
    }
    
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



