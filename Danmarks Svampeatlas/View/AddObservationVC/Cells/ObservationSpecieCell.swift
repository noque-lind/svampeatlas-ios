//
//  ObservationSpecieCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AddObservationMushroomTableView: ELTableView<AddObservationMushroomTableView.Item> {
    
    enum Item {
        case selectedMushroom(Mushroom, NewObservation.DeterminationConfidence)
        case selectableMushroom(Mushroom, Double?)
        case unknownSpecies
        case unknownSpeciesButton
    }
    
    override init() {
        super.init()
        register(cellClass: UnknownSpecieCell.self, forCellReuseIdentifier: UnknownSpecieCell.identifier)
        register(cellClass: ContainedResultCell.self, forCellReuseIdentifier: ContainedResultCell.identifier)
        register(cellClass: SelectedSpecieCell.self, forCellReuseIdentifier: SelectedSpecieCell.identifier)
        register(cellClass: UnknownSpeciesCellButton.self, forCellReuseIdentifier: UnknownSpeciesCellButton.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func cellForItem(_ item: AddObservationMushroomTableView.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .selectableMushroom(let mushroom, let confidence):
            let cell = tableView.dequeueReusableCell(withIdentifier: ContainedResultCell.identifier, for: indexPath) as! ContainedResultCell
            if let confidence = confidence {
                cell.configureCell(mushroom: mushroom, confidence: confidence)
            } else {
                cell.configureCell(mushroom: mushroom)
            }
            
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .selectedMushroom(let mushroom, let confidence):
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectedSpecieCell.identifier, for: indexPath) as! SelectedSpecieCell
            cell.configureCell(mushroom: mushroom, confidence: confidence)
            
            //            cell.confidenceSelected = { [weak self] determinationConfidence in
            //                self?.newObservation?.determinationConfidence = determinationConfidence
            //            }
            
            cell.accessoryType = .none
            return cell
            
        case .unknownSpecies:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnknownSpecieCell.identifier, for: indexPath) as! UnknownSpecieCell
            
            //            cell.deselectButtonPressed = { [unowned self] in
            //                self.newObservation?.mushroom = nil
            //                self.configureSpeciesSection()
            //            }
            
            return cell
        case .unknownSpeciesButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnknownSpeciesCellButton.identifier, for: indexPath) as! UnknownSpeciesCellButton
            return cell
        }
    }
}

class ObservationSpecieCell: UICollectionViewCell {
    
    //    private class Section {
    //
    //        enum CellType {
    //            case selectedMushroom(Mushroom, NewObservation.DeterminationConfidence)
    //            case selectableMushroom(Mushroom, Double?)
    //            case unknownSpecie
    //            case unknownSpeciesButton
    //            case loader
    //            case error(AppError)
    //        }
    //
    //        var title: String?
    //        var cells: [CellType]
    //        var alpha: CGFloat
    //
    //        init(title: String?, cells: [CellType], alpha: CGFloat = 1.0) {
    //            self.title = title
    //            self.cells = cells
    //            self.alpha = alpha
    //        }
    //
    //        func itemAt(index: Int) -> CellType? {
    //            if let item = cells[safe: index] {
    //                return item
    //            } else {
    //                return nil
    //            }
    //        }
    //
    //        func setTitle(title: String?) {
    //            self.title = title
    //        }
    //
    //        func setCells(cells: [CellType]) {
    //            self.cells = cells
    //        }
    //
    //        func setAlpha(alpha: CGFloat) {
    //            self.alpha = alpha
    //        }
    //    }
    
    private lazy var searchBar: CustomSearchBar = {
        let view = CustomSearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarDelegate = self
        view.isHidden = false
        return view
    }()
    
    private lazy var tableView: AddObservationMushroomTableView = {
        let tableView = AddObservationMushroomTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.setSections(sections: [speciesSection, suggestionsSection, favoritesSection])
        
//        tableView.didSelectItem = { [unowned self] item, indexPath in
//            switch item {
//            case .unknownSpeciesButton:
//                let vc = DetailsViewController(detailsContent: DetailsContent.mushroomWithID(taxonID: Mushroom.genus().id, takesSelection: (selected: false, title: "Vælg", handler: { (selected) in
//                    self.newObservation?.mushroom = Mushroom.genus()
//                    self.configureSpeciesSection()
//                })))
//
//                self.delegate?.pushVC(vc)
//
//            case .selectableMushroom(let mushroom, _):
//                if mushroom != self.newObservation?.mushroom {
//                    let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: false, title: mushroom.isGenus ? "Vælg slægt": "Vælg art", handler: { (selected) in
//                        self.newObservation?.mushroom = mushroom
//                        self.configureSpeciesSection()
//                    })))
//                    self.delegate?.pushVC(vc)
//                } else {
//                    let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: true, title: "Fravælg", handler: { (selected) in
//                        self.newObservation?.mushroom = nil
//                        self.configureSpeciesSection()
//                    })))
//                    self.delegate?.pushVC(vc)
//                }
//
//            case .selectedMushroom(let mushroom, _):
//                let vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: true, title: "Fravælg", handler: { (selected) in
//                    self.newObservation?.mushroom = nil
//                    self.configureSpeciesSection()
//                })))
//                self.delegate?.pushVC(vc)
//            default:
//                return
//            }
//        }
        
        return tableView
    }()
    
    weak var delegate: NavigationDelegate?
    
    private let speciesSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .items(items: []))
    private let suggestionsSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .items(items: []))
    private let favoritesSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .items(items: []))
    
    private var newObservation: NewObservation? {
        didSet {
            if let newObservation = newObservation {
                newObservation.predictionsResultsStateChanged = { [weak self] in
                    self?.configureSuggestionsSection()
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
        searchBar.isHidden = false
        searchBar.expand()
    }
    
    private func hideSearchBar() {
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0.0, bottom: 0.0, right: 0.0)
        searchBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
        
    func configureCell(newObservation: NewObservation?) {
        self.newObservation = newObservation
        configureSpeciesSection()
//        configureSuggestionsSection()
//        configureFavoritesSection()
        
//        tableView.performUpdates(updates: { [unowned self] updater in
//            updater.updateSection(section: self.speciesSection)
//        })
    }
    
    private func defaultState() {
//        tableViewState = .Items(sections)
    }
    
    private func configureSpeciesSection() {
        if let selectedMushroom = newObservation?.mushroom, let selectedDeterminationConfidence = newObservation?.determinationConfidence {
            hideSearchBar()
            speciesSection.setTitle(title: selectedMushroom.isGenus ? "Valgte slægt": "Valgte art")
            speciesSection.setState(state: .items(items: [.selectedMushroom(selectedMushroom, selectedDeterminationConfidence)]))
        } else {
            showSearchBar()
            speciesSection.setTitle(title: nil)
            speciesSection.setState(state: .items(items: [.unknownSpeciesButton]))
        }
        
        tableView.performUpdates(updates: { [unowned speciesSection] updater in
            updater.updateSection(section: speciesSection)
        })
    }
    
    func configureFavoritesSection() {
        CoreDataHelper.fetchAllFavoritedMushrooms { [weak favoritesSection] (result) in
            switch result {
            case .Error(_):
                break
            case .Success(let mushrooms):
                favoritesSection?.setTitle(title: "Mine favoritter")
                favoritesSection?.setState(state: .items(items: mushrooms.compactMap({AddObservationMushroomTableView.Item.selectableMushroom($0, nil)})))
                
                self.tableView.performUpdates(updates: { [unowned self] updater in
                    updater.updateSection(section: self.favoritesSection)
                })
            }
        }
    }
    
    private func configureSuggestionsSection() {
        if let predictionsState = newObservation?.predictionResultsState {
            switch predictionsState {
            case .Error(let error, nil):
                suggestionsSection.setTitle(title: "Navneforslag")
                suggestionsSection.setState(state: .error(error: error, handler: nil))
            case .Loading:
                suggestionsSection.setTitle(title: "Navneforslag")
                suggestionsSection.setState(state: .loading)
            case .Items(let predictionResults):
                suggestionsSection.setTitle(title: "Navneforslag")
                suggestionsSection.setState(state: .items(items: predictionResults.compactMap({AddObservationMushroomTableView.Item.selectableMushroom($0.mushroom, $0.score)})))
            default:
                suggestionsSection.setTitle(title: nil)
                suggestionsSection.setState(state: .items(items: []))
            }
        } else {
            suggestionsSection.setTitle(title: nil)
            suggestionsSection.setState(state: .items(items: []))
        }
    }
}

extension ObservationSpecieCell {
    

    
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
//        tableViewState = .Loading
        
        DataService.instance.getMushrooms(searchString: entry, speciesQueries: [.attributes(presentInDenmark: nil), .images(required: false), .danishNames, .redlistData, .statistics]) { [weak self] (result) in
            switch result {
            case .Error(let appError):
                return
//                self?.tableViewState = TableViewState.Error(appError, nil)
            case .Success(let mushrooms):
                return
//                let cells = mushrooms.compactMap({Section.CellType.selectableMushroom($0, nil)})
//                self?.tableViewState = TableViewState.Items([Section.init(title: "Søgeresultater", cells: cells)])
            }
        }
    }
    
    func clearedSearchEntry() {
        defaultState()
    }
}
