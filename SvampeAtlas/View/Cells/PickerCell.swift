//
//  PickerCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol PickerCellDelegate: class {
    func substrateSelected(substrateGroup: Substrate)
    func dateSelected(date: Date)
    func vegetationType(vegetationType: VegetationType)
}

class PickerCell: UITableViewCell {
    
    enum PickerType {
        case Date
        case SubstrateGroups
        case VegetationTypes
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        view.tintColor = UIColor.appWhite()
        view.setValue(UIColor.appWhite(), forKeyPath: "textColor")
        view.maximumDate = Date()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(handleDatePickerValueChanged), for: UIControl.Event.valueChanged)
        return view
    }()
    
    private lazy var picker: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        view.showsSelectionIndicator = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor.appWhite()
        return view
    }()
    
    private var pickerType: PickerType
    private var substrateGroups = [SubstrateGroup]()
    private var vegetationTypes = [VegetationType]()
    private var date = Date()
    weak var delegate: PickerCellDelegate?
    
    init(reuseIdentifier: String, pickerType: PickerType) {
        self.pickerType = pickerType
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        picker.isHidden = true
        datePicker.isHidden = true
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        switch pickerType {
        case .Date:
            contentView.addSubview(datePicker)
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
        case .SubstrateGroups, .VegetationTypes:
            contentView.addSubview(tableView)
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        }
    }
    
    func configure(date: Date) {
        guard pickerType == .Date else {return}
        datePicker.date = date
    }
    
    func configure(substrateGroups: [SubstrateGroup]) {
        guard pickerType == .SubstrateGroups else {return}
        self.substrateGroups = substrateGroups
        tableView.reloadData()
    }
    
    func configure(vegetationTypes: [VegetationType]) {
        guard pickerType == .VegetationTypes else {return}
        self.vegetationTypes = vegetationTypes
        tableView.reloadData()
        
    }
    
    @objc private func handleDatePickerValueChanged() {
        delegate?.dateSelected(date: datePicker.date)
    }
}



extension PickerCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch pickerType {
        case .SubstrateGroups:
            return substrateGroups.count
        case .VegetationTypes:
            return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pickerType {
        case .SubstrateGroups:
            return substrateGroups[section].substrates.count
        case .VegetationTypes:
            return vegetationTypes.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch pickerType {
        case .SubstrateGroups:
            return 30
        default: return 0
    }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if pickerType == .SubstrateGroups {
            let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: tableView.sectionHeaderHeight))
            view.backgroundColor = UIColor.appPrimaryColour()
            
            let label: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = UIColor.appWhite()
                label.text = substrateGroups[section].dkName.capitalizeFirst()
                return label
            }()
            
            view.addSubview(label)
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "contentCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "contentCell")
        }
        
        let selectionView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.appThirdColour()
            return view
        }()
        cell?.selectedBackgroundView = selectionView
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = UIColor.appWhite()
        cell?.textLabel?.font = UIFont.appPrimaryHightlighed()
        
        switch pickerType {
        case .SubstrateGroups:
            cell?.textLabel?.text = "   - \(substrateGroups[indexPath.section].substrates[indexPath.row].dkName)"
        case .VegetationTypes:
            cell?.textLabel?.text = vegetationTypes[indexPath.row].dkName
        default: break
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch pickerType {
        case .VegetationTypes:
            delegate?.vegetationType(vegetationType: vegetationTypes[indexPath.row])
        case .SubstrateGroups:
            delegate?.substrateSelected(substrateGroup: substrateGroups[indexPath.section].substrates[indexPath.row])
        default: return
        }
    }
}

extension PickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        if substrateGroups.count != 0 {
        //            if component == 0 {
        //                initialIndex = row
        //                pickerView.reloadComponent(1)
        //            }
        //        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}
