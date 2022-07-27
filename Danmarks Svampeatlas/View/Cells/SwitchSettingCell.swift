//
//  SettingCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/01/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class SwitchSettingCell: UITableViewCell {
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switcher: UISwitch = {
       let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = UIColor.appThird()
        view.tintColor = UIColor.appPrimaryColour()
        view.addTarget(self, action: #selector(switchValueSet), for: .valueChanged)
        return view
    }()
    
    @objc private func switchValueSet() {
        onValueSet?(switcher.isOn)
    }
    
    var onValueSet: ((_ newValue: Bool) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        
        let stackView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.spacing = 16
            view.distribution = .fill
            view.alignment = .center
            view.clipsToBounds = false
            view.addArrangedSubview(descriptionLabel)
            view.addArrangedSubview(switcher)
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
    
    func configureCell(description: String, value: Bool, onValueSet: @escaping ((_ newValue: Bool) -> ())) {
        descriptionLabel.text = description
        switcher.isOn = value
        self.onValueSet = onValueSet
    }
}

