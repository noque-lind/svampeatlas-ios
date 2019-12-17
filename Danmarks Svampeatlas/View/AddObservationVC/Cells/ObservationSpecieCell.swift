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
        case citation
    }
    
    var isAtTop: ((Bool) -> ())?
    var confidenceSelected: ((NewObservation.DeterminationConfidence) -> ())?
    
    
    override init() {
        super.init()
        register(cellClass: UnknownSpecieCell.self, forCellReuseIdentifier: UnknownSpecieCell.identifier)
        register(cellClass: ContainedResultCell.self, forCellReuseIdentifier: ContainedResultCell.identifier)
        register(cellClass: SelectedSpecieCell.self, forCellReuseIdentifier: SelectedSpecieCell.identifier)
        register(cellClass: UnknownSpeciesCellButton.self, forCellReuseIdentifier: UnknownSpeciesCellButton.identifier)
        register(cellClass: CreditationCell.self, forCellReuseIdentifier: CreditationCell.identifier)
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
            cell.confidenceSelected = confidenceSelected
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
        case .citation:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreditationCell.identifier, for: indexPath) as! CreditationCell
            cell.configureCell(creditation: .AINewObservation)
            return cell
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            isAtTop?(true)
        } else {
            isAtTop?(false)
        }
    }
}

class ObservationSpecieCell: UICollectionViewCell {
    
    private lazy var searchBar: SearchBar = {
        let view = SearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.searchBarDelegate = self
        view.isHidden = false
        return view
    }()
    
    private lazy var tableView: AddObservationMushroomTableView = {
        let tableView = AddObservationMushroomTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        tableView.isAtTop = { [unowned searchBar] isAtTop in
            if isAtTop {
                searchBar.expand()
            } else {
                searchBar.collapse()
            }
        }
        
        tableView.didSelectItem = { [unowned self, unowned tableView] item, _ in
            let vc: UIViewController
            switch item {
            case .unknownSpeciesButton:
                vc = DetailsViewController(detailsContent: DetailsContent.mushroomWithID(taxonID: Mushroom.genus().id, takesSelection: (selected: false, title: "Vælg", handler: { (selected) in
                    self.newObservation?.mushroom = Mushroom.genus()
                    self.configureUpperSection()
                    self.configurePredictions()
                    
                    tableView.performUpdates(updates: { (updater) in
                        updater.updateSection(section: self.upperSection)
                        updater.updateSection(section: self.middleSection)
                        updater.scrollToTop(animated: true)
                    })
                })))
            case .selectableMushroom(let mushroom, _):
                let selected = mushroom == self.newObservation?.mushroom
                vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: selected, title: selected ? "Fravælg": (mushroom.isGenus ? "Vælg slægt": "Vælg art"), handler: { (_) in
                    
                    if selected {
                        self.newObservation?.mushroom = nil
                    } else {
                        self.newObservation?.mushroom = mushroom
                    }
                    
                    self.configureUpperSection()
                    self.configurePredictions()
                    
                    tableView.performUpdates(updates: { (updater) in
                        updater.updateSection(section: self.upperSection)
                        updater.updateSection(section: self.middleSection)
                        updater.scrollToTop(animated: false)
                    }) {
                        tableView.scrollToTop(animated: true)
                    }
                })))
            case .selectedMushroom(let mushroom, _):
                vc = DetailsViewController(detailsContent: DetailsContent.mushroom(mushroom: mushroom, session: nil, takesSelection: (selected: true, title: "Fravælg", handler: { (selected) in
                    self.newObservation?.mushroom = nil
                    self.configureUpperSection()
                    
                    tableView.performUpdates(updates: { (updater) in
                        updater.updateSection(section: self.upperSection)
                        updater.scrollToTop(animated: true)
                    })
                })))
                
            default:
                return
            }
            self.delegate?.pushVC(vc)
        }
    
        tableView.setSections(sections: [upperSection, middleSection, lowerSection])
        return tableView
    }()
    
    weak var delegate: NavigationDelegate?
    
    private let upperSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .empty)
    private let middleSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .empty)
    private let lowerSection = Section<AddObservationMushroomTableView.Item>.init(title: nil, state: .empty)
    
    private var newObservation: NewObservation? {
        didSet {
            newObservation?.predictionsResultsStateChanged = { [weak self] in
                self?.configurePredictions()
                self?.tableView.performUpdates(updates: { updater in
                    updater.updateSection(section: self?.middleSection)
                })
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
        configureUpperSection()
        configurePredictions()
        configureFavoritesSection()
    }
    
    
    private func configureUpperSection() {
        if let selectedMushroom = newObservation?.mushroom, let selectedDeterminationConfidence = newObservation?.determinationConfidence {
            hideSearchBar()
            upperSection.setTitle(title: selectedMushroom.isGenus ? "Valgte slægt": "Valgte art")
            upperSection.setState(state: .items(items: [.selectedMushroom(selectedMushroom, selectedDeterminationConfidence)]))
        } else {
            showSearchBar()
            upperSection.setTitle(title: nil)
            upperSection.setState(state: .items(items: [.unknownSpeciesButton]))
        }
    }
    
    private func configureFavoritesSection() {
        CoreDataHelper.fetchAllFavoritedMushrooms { [weak lowerSection] (result) in
            switch result {
            case .Error(_): return
            case .Success(let mushrooms):
                lowerSection?.setTitle(title: "Mine favoritter")
                lowerSection?.setState(state: .items(items: mushrooms.compactMap({AddObservationMushroomTableView.Item.selectableMushroom($0, nil)})))
            }
        }
    }
    
    private func configurePredictions() {
        searchBar.text = nil
        middleSection.setTitle(title: "Navneforslag")
        
        if let predictionsState = newObservation?.predictionResultsState {
            switch predictionsState {
            case .error(error: let error, handler: _):
                middleSection.setState(state: .error(error: error, handler: nil))
            case .loading:
                middleSection.setState(state: .loading)
            case .items(items: let items):
                var items = items.compactMap({AddObservationMushroomTableView.Item.selectableMushroom($0.mushroom, $0.score)})
                items.append(.citation)
                middleSection.setState(state: .items(items: items))
            case .empty:
                middleSection.setState(state: .empty)
            }
        }
    }
}

extension ObservationSpecieCell: CustomSearchBarDelegate {
    func newSearchEntry(entry: String) {
        middleSection.setTitle(title: "Søgeresultater")
        middleSection.setState(state: .loading)
        
        tableView.performUpdates(updates: { (updater) in
            updater.updateSection(section: self.middleSection)
        }) { [weak middleSection, weak tableView] in
            DataService.instance.getMushrooms(searchString: entry, speciesQueries: [.attributes(presentInDenmark: nil), .images(required: false), .danishNames, .redlistData, .statistics]) { (result) in
                switch result {
                case .Error(let appError):
                    middleSection?.setState(state: .error(error: appError, handler: nil))
                case .Success(let mushrooms):
                    middleSection?.setState(state: .items(items: mushrooms.compactMap({AddObservationMushroomTableView.Item.selectableMushroom($0, nil)})))
                }
                
                tableView?.performUpdates(updates: { updater in
                    updater.updateSection(section: middleSection)
                })
            }
        }
    }
    
    func clearedSearchEntry() {
        configurePredictions()
        
        tableView.performUpdates(updates: { updater in
            updater.updateSection(section: self.middleSection)
        })
    }
}
