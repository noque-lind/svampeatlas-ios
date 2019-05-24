//
//  ObservationDetailsCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

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
        view.estimatedRowHeight = 200
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(SettingCell.self, forCellReuseIdentifier: "selectorCell")
        view.register(PickerViewCell.self, forCellReuseIdentifier: "PickerViewCell")
        view.register(TableViewPickerCell.self, forCellReuseIdentifier: "TableViewPickerCell")
        view.register(TextViewCell.self, forCellReuseIdentifier: "textViewCell")
        return view
    }()
    
    private let rows: [Categories] = [.Date, .Substrate, .VegetationType, .Host, .EcologyNotes, .Notes]
    private var newObservation: NewObservation?
    private var shouldClearObservationHost = false
    private var addedRow: (parent: IndexPath, indexPath: IndexPath, selectors: Selectors)? {
        didSet {
            if let oldValue = oldValue, addedRow == nil {
                tableView.deleteRows(at: [oldValue.indexPath], with: .fade)
                tableView.deselectRow(at: oldValue.parent, animated: true)
            }
            
            guard let addedRow = addedRow else {return}
                tableView.insertRows(at: [addedRow.indexPath], with: .fade)
            // add the new addedrow to the tableView
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func configure(newObservation: NewObservation) {
        self.newObservation = newObservation
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
        case .hostCell(let host):
            if shouldClearObservationHost {
                newObservation?.hosts.removeAll()
                shouldClearObservationHost = false
            }
            
            if let indexPath = newObservation?.hosts.firstIndex(where: {$0.id == host.id}) {
                newObservation?.hosts.remove(at: indexPath)
            } else {
                newObservation?.hosts.append(host)
            }
            
            if isLocked == true, let hosts = newObservation?.hosts {
                UserDefaultsHelper.setDefaultHosts(hosts: hosts)
                newObservation?.lockedHosts = true
            } else {
                UserDefaultsHelper.setDefaultHosts(hosts: [])
                newObservation?.lockedHosts = false
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
            
            newObservation?.substrate = substrate
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
            
            newObservation?.vegetationType = vegetationType
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
                return 45
            case .Notes, .EcologyNotes:
                return UITableView.automaticDimension
            }
    }
    
    
    fileprivate func getVegetationTypes(forCell cell: TableViewPickerCell) {
        cell.tableViewState = .Loading
        
        DataService.instance.getVegetationTypes { (result) in
            switch result {
            case .Success(let vegetationTypes):
                cell.tableViewState = .Items([.init(title: nil, cells: vegetationTypes.compactMap({TableViewPickerCell.Section.CellType.vegetationTypeCell($0)}))])

            case .Error(let error):
                cell.tableViewState = .Error(error, {
                    self.getVegetationTypes(forCell: cell)
                })
            }
        }
    }
    
    fileprivate func getSubstrateGroups(forCell cell: TableViewPickerCell) {
        cell.tableViewState = .Loading
        
        DataService.instance.getSubstrateGroups { (result) in
            switch result {
            case .Error(let error):
                cell.tableViewState = .Error(error, {
                    self.getSubstrateGroups(forCell: cell)
                })
            case .Success(let substrateGroups):
                    let sections = substrateGroups.compactMap({TableViewPickerCell.Section.init(title: $0.dkName.capitalizeFirst(), cells: $0.substrates.compactMap({TableViewPickerCell.Section.CellType.substrateCell($0)}))})
                cell.tableViewState = .Items(sections)
            }
        }
    }
    
    fileprivate func getHosts(forCell cell: TableViewPickerCell) {
        DataService.instance.getHosts { (result) in
            switch result {
            case .Error(let error):
                cell.tableViewState = .Error(error, nil)
            case .Success(let hosts):
                let cells = hosts.compactMap({TableViewPickerCell.Section.CellType.hostCell($0)})
                cell.tableViewState = .Items([.init(title: "Forslag", cells: cells)])
            }
        }
        
//        switch CoreDataHelper.getFavoriteHosts() {
//        case .Error(let error):
//            cell.configureCell(tableViewPickerCellType: .Hosts(.Error(error, nil)))
//        case .Success(let hosts):
//            cell.configureCell(tableViewPickerCellType: .Hosts(.Items(hosts)))
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let addedRow = addedRow, indexPath.row == addedRow.indexPath.row {
            switch addedRow.selectors {
            case .DateSelector:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! PickerViewCell
                cell.didPickDate = { [unowned self] date in
                    self.newObservation?.observationDate = date
                    guard let index = self.rows.firstIndex(of: .Date) else {return}
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                cell.configure(date: newObservation!.observationDate)
                return cell
            case .SubstraPicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
                }
                getSubstrateGroups(forCell: cell)
                return cell
            case .VegetationPicker:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
                }
                getVegetationTypes(forCell: cell)
                return cell
            case .HostSelector:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPickerCell", for: indexPath) as! TableViewPickerCell
                cell.didSelectCell = { [unowned self] cellType, isLocked in
                    self.didSelectCell(cellType: cellType, isLocked: isLocked)
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
                switch rows[indexPath.row] {
                case .Date:
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Date"), description: "Dato:", content: newObservation!.observationDate.convert(into: DateFormatter.Style.medium, ignoreRecentFormatting: true))
                    
                case .Substrate:
                    var string = newObservation?.substrate?.isLocked == true  ? "🔒 ": ""
                    string.append(newObservation?.substrate?.dkName ?? "*")
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Substrate"), description: "Substrat:", content: string)
                    
                case .VegetationType:
                    var string = newObservation?.vegetationType?.isLocked == true ? "🔒 ": ""
                    string.append(newObservation?.vegetationType?.dkName ?? "*")
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_VegetationType"), description: "Vegetationstype:", content: string)
                case .Host:
                    var string = newObservation?.lockedHosts == true ? "🔒 ": ""
                
                    if let hosts = newObservation?.hosts, hosts.count != 0 {
                        for host in hosts {
                            string.append(contentsOf: "\(host.dkName ?? ""), ")
                        }
                        string.removeLast()
                        string.removeLast()
                    } else {
                        string = "-"
                    }
                    
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_VegetationType"), description: "Vært", content: string)
                    
                default: break
                }
                
                return cell
                
            case .Notes, .EcologyNotes:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewCell
                
                switch rows[realIndexPathRow] {
                case .Notes:
                    cell.configureCell(titleText: "Andre noter", placeholder: "Lugt melagtig ...", content: newObservation?.note, delegate: self)
                case .EcologyNotes:
                    cell.configureCell(titleText: "Kommentarer om voksested", placeholder: "På sandjord blandt mos ...", content: newObservation?.ecologyNote, delegate: self)
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
    
    func didUpdateTextEntry(title: String, _ text: String) {
        switch title {
        case "Noter":
            newObservation?.note = text
        case "Økologi kommentarer":
            newObservation?.ecologyNote = text
        default: return
        }
    }
}
