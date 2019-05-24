//
//  ObservationSpecieCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationSpecieCell: UICollectionViewCell {
    
    private struct Section {
        enum CellType {
            case selectedMushroom(Mushroom)
            case selectableMushroom(Mushroom)
            case unknownSpecie
        }
        
        let title: String?
        let cells: [CellType]
        let alpha: CGFloat
        
        init(title: String?, cells: [CellType], alpha: CGFloat = 1.0) {
            self.title = title
            self.cells = cells
            self.alpha = alpha
        }
    }
    
    private lazy var searchBar: CustomSearchBar = {
        let view = CustomSearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarDelegate = self
        view.isHidden = false
        return view
    }()
    
    private lazy var tableView: AppTableView = {
        let tableView = AppTableView(animating: true, frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UnknownSpecieCell.self, forCellReuseIdentifier: "unknownSpecieCell")
        tableView.register(ContainedResultCell.self, forCellReuseIdentifier: "resultCell")
        tableView.register(SelectedSpecieCell.self, forCellReuseIdentifier: "selectedSpecieCell")
        return tableView
    }()
    
    weak var delegate: NavigationDelegate?
    private var sections = [Section]()
    private var newObservation: NewObservation?
    
    private var tableViewState: TableViewState<Section> = .None {
        didSet {
            switch tableViewState {
            case .Empty:
                DispatchQueue.main.async {
                    self.searchBar.expand()
                    self.searchBar.text = nil
                    self.showSearchBar()
                }
            case .Loading:
                tableView.showLoader()
            case .Items(_):
                break
            case .Error(let error, let handler):
                self.tableView.showError(error, handler: handler)
            case .None:
                break
            case .Paging:
                break
            }
            if case .None = oldValue {
                return
            } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        contentView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        searchBar.leadingConstraint = searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
    }
    
    private func showSearchBar() {
        tableView.contentInset = UIEdgeInsets(top: 62, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 58, left: 0.0, bottom: 0.0, right: 0.0)
        searchBar.isHidden = false
        searchBar.expand()
    }
    
    private func hideSearchBar() {
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 4, left: 0.0, bottom: 0.0, right: 0.0)
        searchBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    private func defaultState() {
        self.newObservation?.mushroom = nil
        self.showSearchBar()
        searchBar.text = ""
        var sections = [Section(title: "Art af Svamp (Fungi sp.)", cells: [.unknownSpecie])]
        
        CoreDataHelper.fetchAllFavoritedMushrooms { (result) in
            switch result {
            case .Error(_):
                return
            case .Success(let mushrooms):
                let cells = mushrooms.compactMap({Section.CellType.selectableMushroom($0)})
                sections.append(Section(title: "Mine favoritter", cells: cells, alpha: 0.2))
            }
            self.tableViewState = TableViewState.Items(sections)
        }
    }
    
    
    func configureCell(newObservation: NewObservation?) {
        self.newObservation = newObservation
        
        if let selectedMushroom = newObservation?.mushroom {
            self.tableViewState = TableViewState.Items([Section.init(title: "Valgt art", cells: [ObservationSpecieCell.Section.CellType.selectedMushroom(selectedMushroom)])])
            self.hideSearchBar()
        } else {
            defaultState()
        }
    }
}

extension ObservationSpecieCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewState.itemsCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = tableViewState.value(row: section) else {return 0}
        return section.cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableViewState.value(row: section)?.title != nil else {return 0}
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = tableViewState.value(row: section)?.title else {return nil}
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFooterView") as? HeaderView
        if view == nil {
            view = HeaderView(reuseIdentifier: "headerFooterView")
        }
        view?.label.text = title
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = tableViewState.value(row: indexPath.section) else {fatalError()}
        switch section.cells[indexPath.row] {
        case .selectableMushroom(let mushroom):
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ContainedResultCell
            cell.configureCell(mushroom: mushroom)
            cell.accessoryType = .disclosureIndicator
            print(section.alpha)
            cell.alpha = section.alpha
            return cell
            
        case .selectedMushroom(let mushroom):
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedSpecieCell", for: indexPath) as! SelectedSpecieCell
            cell.configureCell(mushroom: mushroom)
            cell.accessoryType = .none
            cell.alpha = section.alpha
            return cell
            
        case .unknownSpecie:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unknownSpecieCell", for: indexPath) as! UnknownSpecieCell
            cell.alpha = section.alpha
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = tableViewState.value(row: indexPath.section)?.cells else {fatalError()}
        
        switch section[indexPath.row] {
        case .selectedMushroom(_):
            return 300
        case .unknownSpecie:
            return 90
        default:
            return 75
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = tableViewState.value(row: indexPath.section)?.cells else {fatalError()}
        
        switch section[indexPath.row] {
        case .selectableMushroom(let mushroom):
            
            let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, takesSelection: (selected: false, handler: { (selected) in
                self.tableViewState = TableViewState.Items([Section.init(title: "Valgt art", cells: [ObservationSpecieCell.Section.CellType.selectedMushroom(mushroom)])])
                self.newObservation?.mushroom = mushroom
                self.hideSearchBar()
                
            })))
            self.delegate?.pushVC(vc)
            
        case .selectedMushroom(let mushroom):
            let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, takesSelection: (selected: true, handler: { (selected) in
                self.defaultState()
            })))
            self.delegate?.pushVC(vc)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SelectedSpecieCell else {return}
        cell.fade()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            searchBar.expand()
        } else {
            searchBar.collapse()
        }
    }
}

extension ObservationSpecieCell: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        
        tableViewState = .Loading
        
        DataService.instance.getMushroomsThatFitSearch(searchString: entry) { (result) in
            switch result {
            case .Error(let appError):
                self.tableViewState = TableViewState.Error(appError, nil)
            case .Success(let mushrooms):
                let cells = mushrooms.compactMap({Section.CellType.selectableMushroom($0)})
                self.tableViewState = TableViewState.Items([Section.init(title: nil, cells: cells)])
            }
        }
    }
    
    func clearedSearchEntry() {
        defaultState()
    }
}
