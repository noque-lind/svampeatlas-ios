//
//  MapViewSettingsView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum MapViewOptionsType {
    case listView
    case mapView
}


class MapViewSettingsView: UIView {

    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(OptionsCell.self, forCellReuseIdentifier: "optionsCell")
        return tableView
    }()
    
    
    private lazy var settingsButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "Settings"), for: [])
        button.addTarget(self, action: #selector(settingsButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    
    private var isExpanded = false
    private var heightConstraint = NSLayoutConstraint()
    private var widthConstraint = NSLayoutConstraint()
    private var optionItems = [MapViewOptionsType.listView, MapViewOptionsType.mapView]
    
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) not implemented in mapViewSettingsView")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    
    private func setupView() {
        widthConstraint = widthAnchor.constraint(equalToConstant: 40)
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        backgroundColor = UIColor.appSecondaryColour()
        
        
        addSubview(settingsButton)
        settingsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: heightConstraint.constant - 4).isActive = true

    }
    
    
    
    private func expand() {
        heightConstraint.constant = 130
        setupOptions()
        settingsButton.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.superview!.layoutIfNeeded()
        }) { (_) in
            self.isExpanded = true
        }
    }
    
    func collapse() {
        heightConstraint.constant = 40
        settingsButton.setImage(#imageLiteral(resourceName: "Settings"), for: [])
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.superview!.layoutIfNeeded()
        }) { (_) in
            self.isExpanded = false
        }
    }
    
    
    private func setupOptions() {
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        tableView.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: 2).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
}

extension MapViewSettingsView {
    @objc func settingsButtonPressed(sender: UIButton) {
        if isExpanded {
            collapse()
        } else {
             expand()
        }
    }
}

extension MapViewSettingsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsCell
        switch optionItems[indexPath.row] {
        case .listView:
            cell.configureCell(icon: #imageLiteral(resourceName: "IMG_15270"))
        case .mapView:
            cell.configureCell(icon: #imageLiteral(resourceName: "Settings"))
    }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collapse()
    }
}

fileprivate class OptionsCell: UITableViewCell {
    
    private var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    private func setupView() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
    contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true
        iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
    }
    
    func configureCell(icon: UIImage) {
        iconImageView.image = icon
    }
}
