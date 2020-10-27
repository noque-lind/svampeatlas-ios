//
//  PickerCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class PickerViewCell: UITableViewCell {
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        if #available(iOS 13.4, *) {
            view.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        view.datePickerMode = .date
        view.tintColor = UIColor.appPrimaryColour()
        view.setValue(UIColor.appPrimaryColour(), forKeyPath: "textColor")
        view.maximumDate = Date()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(handleDatePickerValueChanged), for: UIControl.Event.valueChanged)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var didPickDate: ((_ date: Date) -> ())?
    
    private func setupView() {
        backgroundColor = UIColor.appWhite()
        contentView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    func configure(date: Date) {
        datePicker.date = date
    }
    
    @objc private func handleDatePickerValueChanged() {
        didPickDate?(datePicker.date)
    }
}

class SwitchHeaderView: UIView {
    
    private var switcher: UISwitch = {
       let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = UIColor.appThird()
        view.tintColor = UIColor.appPrimaryColour()
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.appGreen()
        
        let stackView: UIStackView = {
           let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            
            let label: UILabel = {
               let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = NSLocalizedString("pickerCell_rememberChoice", comment: "")
                return label
            }()
            
            view.addArrangedSubview(label)
            view.addArrangedSubview(switcher)
            return view
        }()
        
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
    }
    
    var isOn: Bool {
        set {
                switcher.setOn(newValue, animated: false)
        } get {
            return switcher.isOn
        }
    }
}

class TableViewPickerCell: UITableViewCell {
    
    class Section {
        enum CellType {
            case substrateCell(Substrate)
            case vegetationTypeCell(VegetationType)
            case searchCell
            
            /**
            - parameters:
             - Host: The host associated with the cell
             - Bool: Whether, or whether not the host is selected already.
            */
            case hostCell(Host, Bool)
            
            mutating func toggleSelected() {
                switch self {
                case .hostCell(let host, let selected):
                    self = .hostCell(host, !selected)
                default:
                    return
                }
            }
        }
        
        let title: String?
        var cells: [CellType]
        
        init(title: String?, cells: [CellType]) {
            self.title = title
            self.cells = cells
        }
    }
    
   
    private var switchHeaderView: SwitchHeaderView = {
       let view = SwitchHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: AppTableView = {
        let tableView = AppTableView(animating: false, frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.allowsMultipleSelection = false
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SearchCell.self, forCellReuseIdentifier: "searchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()
    
    var tableViewState: TableViewState<Section> = .None {
        didSet {
            switch tableViewState {
            case .Loading:
                self.tableView.showLoader()
            case .Error(let error, let handler):
                self.tableView.showError(error, handler: handler)
            default: break
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    var didSelectCell: ((_ cellType: Section.CellType, _ isLocked: Bool) -> ())?
    var presentVC: ((UIViewController) -> ())?
    var isLocked: Bool = false {
        didSet {
            switchHeaderView.isOn = isLocked
        }
    }
    
    override func prepareForReuse() {
        tableView.setContentOffset(CGPoint.zero, animated: false)
        switchHeaderView.isOn = false
        tableViewState = .Empty
        tableView.reloadData()
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = UIColor.white
        contentView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        tableView.tableHeaderView = switchHeaderView
        switchHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        switchHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        switchHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.layoutIfNeeded()
        tableView.tableHeaderView = tableView.tableHeaderView
    }
}


extension TableViewPickerCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewState.itemsCount()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = tableViewState.value(row: section) else {return 0}
        return section.cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = tableViewState.value(row: section), section.title != nil, section.title != "" else {return 0}
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = tableViewState.value(row: section), let title = section.title else {return nil}
    
        if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "tableViewHeaderView") as? HeaderView {
            view.label.text = title
            return view
        } else {
            let view = HeaderView(reuseIdentifier: "tableViewHeaderView")
            view.label.text = title
            view.label.textColor = UIColor.appPrimaryColour()
            view.backgroundView?.backgroundColor = UIColor.lightGray
            view.layer.shadowOpacity = 0.0
            view.layer.shadowOffset = CGSize(width: 0.0, height: 2.5)
            view.layer.shadowRadius = 1.5
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = tableViewState.value(row: indexPath.section) else {fatalError()}
        
        if case .searchCell = section.cells[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
            cell.searchButtonPressed = { [unowned self] in
                let searchVC = SearchVC()
                searchVC.modalPresentationStyle = .overCurrentContext
                searchVC.modalTransitionStyle = .coverVertical
                searchVC.didSelectItem = { host in
                    var currentItems = self.tableViewState.currentItems()
                    currentItems.insert(Section(title: nil, cells: [.hostCell(host, true)]), at: 1)
                    
                    self.didSelectCell?(.hostCell(host, true), self.switchHeaderView.isOn)
                    self.tableViewState = .Items(currentItems)
                }
                
                self.presentVC?(searchVC)
            }
            return cell
        
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
            
            let selectionView: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor.appThird()
                return view
            }()
            cell.selectedBackgroundView = selectionView
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.appPrimaryColour()
            cell.textLabel?.font = UIFont.appPrimaryHightlighed()
            
            switch section.cells[indexPath.row] {
            case .hostCell(let host, let selected):
                tableView.allowsMultipleSelection = true
                
                if Utilities.isDanish() {
                     cell.textLabel?.text = "- \(host.dkName?.capitalizeFirst() ?? "") (\(host.latinName ?? ""))"
                } else {
                    cell.textLabel?.text = "- \(host.latinName?.capitalizeFirst() ?? "")"
                }
                
                if selected {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                return cell
                
            case .substrateCell(let substrate):
                tableView.allowsMultipleSelection = false
                    cell.textLabel?.text = "   - \(substrate.name)"
            
                
                return cell
            case .vegetationTypeCell(let vegetationType):
                tableView.allowsMultipleSelection = false
                      cell.textLabel?.text = "- \(vegetationType.name)"
                
                return cell
            case .searchCell:
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = tableViewState.value(row: indexPath.section) else {return}
        section.cells[indexPath.row].toggleSelected()
        didSelectCell?(section.cells[indexPath.row], switchHeaderView.isOn)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let section = tableViewState.value(row: indexPath.section) else {return}
        section.cells[indexPath.row].toggleSelected()
        didSelectCell?(section.cells[indexPath.row], switchHeaderView.isOn)
    }
}
