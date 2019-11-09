//
//  ObservationSpecieCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationSpecieCell: UICollectionViewCell {
    
    private class Section {
        
        enum CellType {
            case selectedMushroom(Mushroom, NewObservation.DeterminationConfidence)
            case selectableMushroom(Mushroom, Double?)
            case unknownSpecie
            case unknownSpeciesButton
            case loader
            case error(AppError)
        }
        
        var title: String?
        var cells: [CellType]
        var alpha: CGFloat
        
        init(title: String?, cells: [CellType], alpha: CGFloat = 1.0) {
            self.title = title
            self.cells = cells
            self.alpha = alpha
        }
        
        func itemAt(index: Int) -> CellType? {
            if let item = cells[safe: index] {
                return item
            } else {
                return nil
            }
        }
        
        func setTitle(title: String?) {
            self.title = title
        }
        
        func setCells(cells: [CellType]) {
            self.cells = cells
        }
        
        func setAlpha(alpha: CGFloat) {
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UnknownSpecieCell.self, forCellReuseIdentifier: "unknownSpecieCell")
        tableView.register(ContainedResultCell.self, forCellReuseIdentifier: "resultCell")
        tableView.register(SelectedSpecieCell.self, forCellReuseIdentifier: "selectedSpecieCell")
        tableView.register(UnknownSpeciesCellButton.self, forCellReuseIdentifier: "unknownSpeciesCellButton")
        tableView.register(ErrorCell.self, forCellReuseIdentifier: "errorCell")
        tableView.register(LoaderCell.self, forCellReuseIdentifier: "loaderCell")
        return tableView
    }()
    
    weak var delegate: NavigationDelegate?
    private let speciesSection = Section(title: nil, cells: [])
    private let suggestionsSection = Section(title: nil, cells: [])
    private let favoritesSection = Section(title: nil, cells: [])
    
    private lazy var sections: [Section] = {
       return [speciesSection, suggestionsSection, favoritesSection]
    }()
    
    private var newObservation: NewObservation? {
        didSet {
            if let newObservation = newObservation {
                     newObservation.predictionsResultsStateChanged = { [weak self] in
                        self?.configureSuggestionsSection()
                }
            }
        }
    }
    
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
        tableView.contentInset = UIEdgeInsets(top: 66, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 66, left: 0.0, bottom: 0.0, right: 0.0)
        searchBar.isHidden = false
        searchBar.expand()
    }
    
    private func hideSearchBar() {
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0.0, bottom: 0.0, right: 0.0)
        searchBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
   
    
    func configureCell(newObservation: NewObservation?) {
        self.newObservation = newObservation
        tableView.beginUpdates()
        configureSpeciesSection()
        configureSuggestionsSection()
        configureFavoritesSection()
        tableView.endUpdates()
    }
    
    private func defaultState() {
        tableViewState = .Items(sections)
    }
    
   private func configureSpeciesSection() {
    if let selectedMushroom = newObservation?.mushroom, let determinationConfidence = newObservation?.determinationConfidence, selectedMushroom != Mushroom.genus() {
               hideSearchBar()
               speciesSection.setTitle(title: "Valgte art")
                speciesSection.setCells(cells: [.selectedMushroom(selectedMushroom, determinationConfidence)])
             } else if newObservation?.mushroom == Mushroom.genus() {
               hideSearchBar()
               speciesSection.setTitle(title: "Valgt")
               speciesSection.setCells(cells: [.unknownSpecie])
             } else {
               showSearchBar()
               speciesSection.setTitle(title: nil)
               speciesSection.setCells(cells: [.unknownSpeciesButton])
           }
    
        defaultState()
       }
       
       func configureFavoritesSection() {
           CoreDataHelper.fetchAllFavoritedMushrooms { [weak self] (result) in
                       switch result {
                       case .Error(_):
                           break
                       case .Success(let mushrooms):
                           self?.favoritesSection.setTitle(title: "Mine favoritter")
                           self?.favoritesSection.setCells(cells: mushrooms.compactMap({Section.CellType.selectableMushroom($0, nil)}))
                           self?.tableView.reloadSections(.init(arrayLiteral: 2), with: .automatic)
                       }
           }
       }
       
      private func configureSuggestionsSection() {
           if let predictionsState = newObservation?.predictionResultsState {
               switch predictionsState {
               case .Error(let error, nil):
                   suggestionsSection.setTitle(title: "Navneforslag")
                   suggestionsSection.setCells(cells: [.error(error)])
               case .Loading:
                   suggestionsSection.setTitle(title: "Navneforslag")
                   suggestionsSection.setCells(cells: [.loader])
               case .Items(let predictionResults):
                   suggestionsSection.setTitle(title: "Navneforslag")
                   suggestionsSection.setCells(cells: predictionResults.compactMap({Section.CellType.selectableMushroom($0.mushroom, $0.score)}))
               default:
                   suggestionsSection.setTitle(title: nil)
                   suggestionsSection.setCells(cells: [])
               }
           } else {
               suggestionsSection.setTitle(title: nil)
               suggestionsSection.setCells(cells: [])
           }
           
           tableView.reloadSections(.init(arrayLiteral: 1), with: .automatic)
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
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = tableViewState.value(row: section)?.title else {return nil}
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeaderView") as? SectionHeaderView
        if view == nil {
            view = SectionHeaderView()
        }
        view?.configure(text: title)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = tableViewState.value(row: section) else {return 0}
        return section.title != nil ? UITableView.automaticDimension: 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = tableViewState.value(row: indexPath.section) else {return UITableViewCell()}
        guard let item = section.itemAt(index: indexPath.row) else {return UITableViewCell()}
        switch item {
        case .selectableMushroom(let mushroom, let confidence):
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ContainedResultCell
            
            if let confidence = confidence {
                cell.configureCell(mushroom: mushroom, confidence: confidence)
                } else {
                cell.configureCell(mushroom: mushroom)
            }
            
            cell.accessoryType = .disclosureIndicator
            cell.alpha = section.alpha
            return cell
            
        case .selectedMushroom(let mushroom, let confidence):
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedSpecieCell", for: indexPath) as! SelectedSpecieCell
            cell.configureCell(mushroom: mushroom, confidence: confidence)
            
            cell.confidenceSelected = { [weak self] determinationConfidence in
                self?.newObservation?.determinationConfidence = determinationConfidence
            }
            
            cell.accessoryType = .none
            cell.alpha = section.alpha
            return cell
            
        case .unknownSpecie:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unknownSpecieCell", for: indexPath) as! UnknownSpecieCell
            cell.alpha = section.alpha
            
            cell.deselectButtonPressed = { [unowned self] in
                self.newObservation?.mushroom = nil
                self.configureSpeciesSection()
            }
            return cell
        case .unknownSpeciesButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unknownSpeciesCellButton", for: indexPath) as! UnknownSpeciesCellButton
            cell.alpha = section.alpha
            return cell
        case .loader:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loaderCell", for: indexPath)
            return cell
        case .error(let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath) as! ErrorCell
            cell.configure(error: error)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = tableViewState.value(row: indexPath.section), let item = section.itemAt(index: indexPath.row), case Section.CellType.loader = item {
            return 150
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = tableViewState.value(row: indexPath.section)?.itemAt(index: indexPath.row) else {return}
        
        switch item {
        case .unknownSpeciesButton:
            let vc = DetailsViewController(detailsContent: DetailsContent.mushroomWithID(taxonID: Mushroom.genus().id, takesSelection: (selected: false, title: "Vælg", handler: { (selected) in
                self.newObservation?.mushroom = Mushroom.genus()
                self.configureSpeciesSection()
            })))
            
            self.delegate?.pushVC(vc)
            
        case .selectableMushroom(let mushroom, _):
            if mushroom != newObservation?.mushroom {
                let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: false, title: mushroom.isGenus ? "Vælg slægt": "Vælg art", handler: { (selected) in
                              self.newObservation?.mushroom = mushroom
                              self.configureSpeciesSection()
                          })))
                          self.delegate?.pushVC(vc)
            } else {
                let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: true, title: "Fravælg", handler: { (selected) in
                    self.newObservation?.mushroom = nil
                    self.configureSpeciesSection()
                        })))
                            self.delegate?.pushVC(vc)
            }
            
            
          
            
        case .selectedMushroom(let mushroom, _):
            let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: true, title: "Fravælg", handler: { (selected) in
                self.newObservation?.mushroom = nil
                self.configureSpeciesSection()
            })))
            self.delegate?.pushVC(vc)
        default:
            return
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

extension ObservationSpecieCell: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        tableViewState = .Loading
        
        DataService.instance.getMushrooms(searchString: entry, speciesQueries: [.attributes(presentInDenmark: nil), .images(required: false), .danishNames, .redlistData, .statistics]) { [weak self] (result) in
            switch result {
            case .Error(let appError):
                self?.tableViewState = TableViewState.Error(appError, nil)
            case .Success(let mushrooms):
                let cells = mushrooms.compactMap({Section.CellType.selectableMushroom($0, nil)})
                self?.tableViewState = TableViewState.Items([Section.init(title: "Søgeresultater", cells: cells)])
            }
        }
    }
    
    func clearedSearchEntry() {
        defaultState()
    }
}
