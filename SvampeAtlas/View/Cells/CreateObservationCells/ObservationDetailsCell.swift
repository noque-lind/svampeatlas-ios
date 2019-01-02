//
//  ObservationDetailsCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum ObservationDetails: CaseIterable {
    case Date
    case VegetationType
    case Substrate
    case Notes
    case EcologyNotes
}

class ObservationDetailsCell: UICollectionViewCell {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorInset = UIEdgeInsets.zero
        view.backgroundColor = UIColor.clear
        view.estimatedRowHeight = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(SelectorCell.self, forCellReuseIdentifier: "selectorCell")
        view.register(PickerCell.self, forCellReuseIdentifier: "pickerCell")
        view.register(TextViewCell.self, forCellReuseIdentifier: "textViewCell")
        return view
    }()
    
    let details = ObservationDetails.allCases
    
    var date = Date()
    var substrate: Substrate?
    var vegetationType: VegetationType?
    var notes: String?
    var ecologyNotes: String?
    
    
    var indexPathNeedingSelectorCell: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func configure(date: Date, substrate: Substrate?, vegetationType: VegetationType?, notes: String?, ecologyNotes: String?) {
        self.date = date
        self.substrate = substrate
        self.vegetationType = vegetationType
        self.notes = notes
        self.ecologyNotes = ecologyNotes
        tableView.reloadData()
    }
    
    private func setupView() {
        contentView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
}

extension ObservationDetailsCell: PickerCellDelegate {
    func vegetationType(vegetationType: VegetationType) {
        self.vegetationType = vegetationType
        guard let index = details.firstIndex(of: .VegetationType) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    func substrateSelected(substrateGroup: Substrate) {
        self.substrate = substrateGroup
        
        guard let index = details.firstIndex(of: .Substrate) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    func dateSelected(date: Date) {
        self.date = date
        guard let index = details.firstIndex(of: .Date) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
    }
}


extension ObservationDetailsCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count + (indexPathNeedingSelectorCell != nil ? 1: 0)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row == indexPathNeedingSelectorCell {
            indexPathNeedingSelectorCell = nil
            tableView.deleteRows(at: [IndexPath.init(row: indexPath.row + 1, section: 0)], with: UITableView.RowAnimation.fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathNeedingSelectorCell = indexPathNeedingSelectorCell, indexPathNeedingSelectorCell != indexPath.row && indexPathNeedingSelectorCell < indexPath.row {
            return IndexPath(row: indexPath.row - 1, section: 0)
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == indexPathNeedingSelectorCell {
            indexPathNeedingSelectorCell = nil
            tableView.deleteRows(at: [IndexPath.init(row: indexPath.row + 1, section: 0)], with: UITableView.RowAnimation.fade)
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        switch details[indexPath.row] {
        case .Date, .Substrate, .VegetationType:
            indexPathNeedingSelectorCell = indexPath.row
            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: UITableView.RowAnimation.fade)
        default: return
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let indexPathNeedingSelectorCell = indexPathNeedingSelectorCell, indexPathNeedingSelectorCell == indexPath.row - 1 {
            
            var cell: PickerCell!
            
            switch details[indexPathNeedingSelectorCell] {
            case .Date:
                cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell") as? PickerCell
                
                if cell == nil {
                    cell = PickerCell(reuseIdentifier: "datePickerCell", pickerType: PickerCell.PickerType.Date)
                }
                
                cell.delegate = self
                cell.configure(date: Date())
                
            case .Substrate:
                cell = tableView.dequeueReusableCell(withIdentifier: "substratePickerCell") as? PickerCell
                
                if cell == nil {
                    cell = PickerCell(reuseIdentifier: "substratePickerCell", pickerType: PickerCell.PickerType.SubstrateGroups)
                    
                    DataService.instance.getSubstrateGroups { (substrateGroups) in
                        DispatchQueue.main.async {
                            cell.configure(substrateGroups: substrateGroups)
                        }
                    }
                }
                
            case .VegetationType:
                cell = tableView.dequeueReusableCell(withIdentifier: "vegetationPickerCell") as? PickerCell
                
                if cell == nil {
                    cell = PickerCell(reuseIdentifier: "vegetationPickerCell", pickerType: PickerCell.PickerType.VegetationTypes)
                    
                    DataService.instance.getVegetationTypes { (vegetationTypes) in
                        DispatchQueue.main.async {
                            cell.configure(vegetationTypes: vegetationTypes)
                        }
                    }
                }
            default:
                break
            }
            cell.delegate = self
            return cell
        } else {
            
            var realIndexPathRow = indexPath.row
            
            if let indexPathNeedingSelectorCell = indexPathNeedingSelectorCell, indexPathNeedingSelectorCell < indexPath.row {
                realIndexPathRow = indexPath.row - 1
            }
            
            switch details[realIndexPathRow] {
            case .Date, .Substrate, .VegetationType:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectorCell", for: indexPath) as! SelectorCell
                switch details[indexPath.row] {
                case .Date:
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Date"), description: "Dato:", content: date.convert(into: DateFormatter.Style.full))
                    
                case .Substrate:
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_Substrate"), description: "Subtrat", content:  substrate?.dkName ?? "Vælg substrat")
                    
                case .VegetationType:
                    cell.configureCell(icon: #imageLiteral(resourceName: "Glyphs_VegetationType"), description: "Vegetationstype", content: vegetationType?.dkName ?? "Vælg vegetationstype")
                    
                default: break
                }
                
                return cell
                
            case .Notes, .EcologyNotes:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewCell
                
                switch details[realIndexPathRow] {
                case .Notes:
                    cell.configureCell(descriptionText: "Noter", placeholder: "Fundet i en meget sjov skov ...", content: "", delegate: self)
                case .EcologyNotes:
                    cell.configureCell(descriptionText: "Økologi kommentarer", placeholder: "Svampen havde store porer ...", content: "", delegate: self)
                default: break
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var realIndexPathRow = indexPath.row
        
        if let indexPathNeedingSelectorCell = indexPathNeedingSelectorCell {
            if indexPathNeedingSelectorCell == indexPath.row - 1 {
                return 200
            } else if indexPathNeedingSelectorCell < indexPath.row {
                realIndexPathRow = indexPath.row - 1
            }
        }
        switch details[realIndexPathRow] {
        case .Date, .Substrate, .VegetationType:
            return 45
        case .EcologyNotes, .Notes:
            return UITableView.automaticDimension
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
