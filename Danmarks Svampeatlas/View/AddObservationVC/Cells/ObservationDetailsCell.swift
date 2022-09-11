//
//  ObservationDetailsCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import UIKit

class ObservationDetailsCell: UICollectionViewCell {
    
    private enum Categories: CaseIterable {
        case Date
        case VegetationType
        case Substrate
        case Host
        case Notes
        case EcologyNotes
    }
    
    private enum Selectors {
        case DateSelector
        case VegetationPicker
        case SubstraPicker
        case HostSelector
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorInset = UIEdgeInsets.zero
        view.backgroundColor = UIColor.clear
        view.separatorColor = UIColor.appWhite()
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset.bottom = self.safeAreaInsets.bottom
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(SettingCell.self, forCellReuseIdentifier: "selectorCell")
        view.register(PickerViewCell.self, forCellReuseIdentifier: "PickerViewCell")
        view.register(TableViewPickerCell.self, forCellReuseIdentifier: "TableViewPickerCell")
        view.register(TextViewCell.self, forCellReuseIdentifier: "textViewCell")
        return view
    }()
    
    weak var viewModel: AddObservationViewModel?
    private let rows = Categories.allCases
    private weak var navigationDelegate: NavigationDelegate?
    private var shouldClearObservationHost = false
    private var didAdjustSafeAreaInsets: Bool = false
    private var addedRow: (parent: IndexPath, indexPath: IndexPath, selectors: Selectors)? {
        didSet {
            if let oldValue = oldValue, addedRow == nil {
                tableView.deleteRows(at: [oldValue.indexPath], with: .fade)
                tableView.deselectRow(at: oldValue.parent, animated: true)
            }
            
            guard let addedRow = addedRow else {return}
                tableView.insertRows(at: [addedRow.indexPath], with: .fade)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if tableView.contentInset.bottom != self.safeAreaInsets.bottom && !didAdjustSafeAreaInsets {
            didAdjustSafeAreaInsets = true
            tableView.contentInset.bottom = self.safeAreaInsets.bottom
            tableView.scrollIndicatorInsets.bottom = self.safeAreaInsets.bottom
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func configure(viewModel: AddObservationViewModel, delegate: NavigationDelegate) {
        self.navigationDelegate = delegate
        self.viewModel = viewModel
        tableView.reloadData()
    }

    private func setupView() {
        contentView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func didSelectCell(cellType: TableViewPickerCell.Section.CellType, isLocked: Bool) {
        switch cellType {
            
        case .hostCell(let host, let selected):
            if selected {
                viewModel?.hosts.items.append(host)
            } else if let indexPath = viewModel?.hosts.items.firstIndex(where: {$0.id == host.id}) {
                viewModel?.hosts.items.remove(at: indexPath)
            }
            viewModel?.hosts.locked = isLocked
            
            if isLocked == true, let hosts = viewModel?.hosts {
                UserDefaultsHelper.setDefaultHosts(hosts: hosts.items)
            } else {
                UserDefaultsHelper.setDefaultHosts(hosts: [])
            }
            
            guard let index = rows.firstIndex(of: .Host) else {return}
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        case .substrateCell(var substrate):
            
            if isLocked {
                substrate.isLocked = true
                UserDefaultsHelper.setDefaultSubstrateID(substrate.id)
            } else {
                UserDefaultsHelper.setDefaultSubstrateID(0)
            }
            
            viewModel?.substrate = substrate
            guard let index = rows.firstIndex(of: .Substrate) else {return}
            let indexPath = IndexPath(row: index, section: 0)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        case .vegetationTypeCell(var vegetationType):
            
            if isLocked {
                vegetationType.isLocked = true
                 UserDefaultsHelper.setDefaultVegetationTypeID(vegetationType.id)
            } else {
                UserDefaultsHelper.setDefaultVegetationTypeID(0)
            }
            
            viewModel?.vegetationType = vegetationType
            guard let index = rows.firstIndex(of: .VegetationType) else {return}
            let indexPath = IndexPath(row: index, section: 0)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        case .searchCell:
            return
        }
    }
}

extension ObservationDetailsCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count + (addedRow != nil ? 1: 0)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let addedRow = addedRow, addedRow.indexPath.row < indexPath.row {
            return IndexPath(row: indexPath.row - 1, section: 0)
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let addedRow = addedRow, addedRow.parent == indexPath {
            self.addedRow = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let addedRow = addedRow, addedRow.parent == indexPath {
            self.addedRow = nil
        } else {
            switch rows[indexPath.row] {
            case .Date:
                addedRow = (indexPath, IndexPath(row: indexPath.row + 1, section: 0), .DateSelector)
            case .Substrate:
                addedRow = (indexPath, IndexPath(row: indexPath.row + 1, section: 0), Selectors.SubstraPicker)
            case .VegetationType:
                addedRow = (indexPath, IndexPath(row: indexPath.row + 1, section: 0), .VegetationPicker)
            case .Host:
                shouldClearObservationHost = true
                addedRow = (indexPath, IndexPath(row: indexPath.row + 1, section: 0), .HostSelector)
            default:
                addedRow = nil
            }
            
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var adjustedIndexPathRow = indexPath.row
        
        if let addedRow = addedRow, addedRow.indexPath == indexPath {
            return 300
        } else if let addedRow = addedRow, addedRow.indexPath.row < indexPath.row {
            adjustedIndexPathRow -= 1
        }

        switch rows[adjustedIndexPathRow] {
            case .Date, .Substrate, .VegetationType, .Host:
                return UITableView.automaticDimension
            case .Notes, .EcologyNotes:
                return UITableView.automaticDimension
            }
    }
    
    fileprivate func getVegetationTypes(forCell cell: TableViewPickerCell) {
        cell.tableViewState = .Loading
        
        DataService.instance.getVegetationTypes { (result) in
            switch result {
            case .success(let vegetationTypes):
                cell.tableViewState = .Items([.init(title: nil, cells: vegetationTypes.compactMap({TableViewPickerCell.Section.CellType.vegetationTypeCell($0)}))])

            case .failure(let error):
                cell.tableViewState = .Error(error, { _ in
                    self.getVegetationTypes(forCell: cell)
                })
            }
        }
    }
    
    fileprivate func getSubstrateGroups(forCell cell: TableViewPickerCell) {
        cell.tableViewState = .Loading
        
        DataService.instance.getSubstrateGroups { [weak cell, weak self] (result) in
            switch result {
            case .failure(let error):
                cell?.tableViewState = .Error(error, {  _ in
                    guard let cell = cell else { return }
                    self?.getSubstrateGroups(forCell: cell)
                })
            case .success(let substrateGroups):
                    let sections = substrateGroups.compactMap({TableViewPickerCell.Section.init(title: $0.name.capitalizeFirst(), cells: $0.substrates.compactMap({TableViewPickerCell.Section.CellType.substrateCell($0)}))})
                cell?.tableViewState = .Items(sections)
            }
        }
    }
    
    fileprivate func getHosts(forCell cell: TableViewPickerCell) {
        DataService.instance.getPopularHosts { (result) in
            switch result {
            case .failure:
                cell.tableViewState = .Items([.init(title: nil, cells: [.searchCell])])
            case .success(var hosts):
                let selectedHosts = self.viewModel?.hosts.items ?? []
                
                let userHosts = hosts.filter({$0.userFound})
                hosts = hosts.filter({!$0.userFound})
                
                let favoriteCells = hosts.compactMap({TableViewPickerCell.Section.CellType.hostCell($0, selectedHosts.contains($0))})
                
                if userHosts.count != 0 {
                    let userCells = userHosts.compactMap({TableViewPickerCell.Section.CellType.hostCell($0, selectedHosts.contains($0))})
                    cell.tableViewState = .Items([.init(title: nil, cells: [.searchCell]), .init(title: nil, cells: userCells), .init(title: NSLocalizedString("observationDetailsCell_mostUsed", comment: ""), cells: favoriteCells)])
                } else {
                    cell.tableViewState = .Items([.init(title: nil, cells: [.searchCell]), .init(title: NSLocalizedString("observationDetailsCell_mostUsed", comment: ""), cells: favoriteCells)])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let addedRow = addedRow, indexPath.row == addedRow.indexPath.row {
            switch addedRow.selectors {
            case .DateSelector:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! PickerViewCell
                cell.didPickDate = { [unowned self] date in
                    self.viewModel?.observationDate = date
                    guard let index = self.rows.firstIndex(of: .Date) else {return}
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                cell.configure(date: viewModel?.observationDate ?? Date())
                return cell
            case .SubstraPicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.isLocked = viewModel?.substrate?.isLocked ?? false
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
                }
                getSubstrateGroups(forCell: cell)
                return cell
            case .VegetationPicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.isLocked = viewModel?.vegetationType?.isLocked ?? false
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
                }
                getVegetationTypes(forCell: cell)
                return cell
            case .HostSelector:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.isLocked = viewModel?.hosts.locked ?? false
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
                }
                
                cell.presentVC = { [unowned self] vc in
                    self.navigationDelegate?.presentVC(vc)
                }
                
                getHosts(forCell: cell)
                return cell
            }
        } else {
            var realIndexPathRow = indexPath.row
            
            if let addedRow = addedRow, addedRow.indexPath.row < indexPath.row {
                realIndexPathRow = indexPath.row - 1
            }
            
            switch rows[realIndexPathRow] {
            case .Date, .Substrate, .VegetationType, .Host:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SettingCell
                switch rows[realIndexPathRow] {
                case .Date:
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Date"), description: NSLocalizedString("observationDetailsCell_date", comment: ""), content: viewModel?.observationDate.convert(into: DateFormatter.Style.medium, ignoreRecentFormatting: true) ?? "")
                    
                case .Substrate:
                    var string = viewModel?.substrate?.isLocked == true  ? "🔒 ": ""
                        string.append(viewModel?.substrate?.name ?? "*")
                    
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Substrate"), description: NSLocalizedString("observationDetailsCell_substrate", comment: ""), content: string)
                    
                case .VegetationType:
                    var string = viewModel?.vegetationType?.isLocked == true ? "🔒 ": ""
                        string.append(viewModel?.vegetationType?.name ?? "*")
                
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_VegetationType"), description: NSLocalizedString("observationDetailsCell_vegetationType", comment: ""), content: string)
                case .Host:
                    var string = viewModel?.hosts.locked == true ? "🔒 ": ""
                
                    if let hosts = viewModel?.hosts.items, hosts.count != 0 {
                        for host in hosts {
                            switch Utilities.appLanguage() {
                            case .czech, .english: string.append(contentsOf: "\(host.latinName ?? ""), ")
                            case .danish: string.append(contentsOf: "\(host.dkName ?? ""), ")
                            }
                        }
                        string.removeLast()
                        string.removeLast()
                    } else {
                        string = "-"
                    }
                    
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Host"), description: NSLocalizedString("observationDetailsCell_host", comment: ""), content: string)
                    
                default: break
                }
                
                return cell
                
            case .Notes, .EcologyNotes:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewCell
                
                switch rows[realIndexPathRow] {
                case .Notes:
                    cell.configureCell(titleText: NSLocalizedString("observationDetailsCell_notes_title", comment: ""), placeholder: NSLocalizedString("observationDetailsCell_notes_message", comment: ""), content: viewModel?.note, delegate: self)
                    
                    cell.textView.didUpdateEntry = { [weak viewModel] entry in
                        viewModel?.note = entry
                    }
                    
                case .EcologyNotes:
                    cell.configureCell(titleText: NSLocalizedString("observationDetailsCell_ecologyNotes_title", comment: ""), placeholder: NSLocalizedString("observationDetailsCell_ecologyNotes_message", comment: ""), content: viewModel?.ecologyNote, delegate: self)
                    
                    cell.textView.didUpdateEntry = { [weak viewModel] entry in
                        viewModel?.ecologyNote = entry
                    }
                default: break
                }
                
                return cell
            }
        }
    }
}

extension ObservationDetailsCell: ELTextViewDelegate {
    func shouldChangeHeight() {
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
