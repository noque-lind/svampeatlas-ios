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

protocol MapViewSettingsViewDelegate: class {
    func wasCollapsed()
    func wasExpanded()
}

class MapViewSettingsView: UIView {

    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.widthAnchor.constraint(equalToConstant: 40).isActive = true
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
    
    private var advancedSettingsView: UIView? {
        didSet {
            if advancedSettingsView == nil {
                radiusSliderLabel = nil
                ageSliderLabel = nil
            }
        }
    }
    
    private var radiusSliderLabel: UILabel?
    private var ageSliderLabel: UILabel?
    
    private var isExpanded = false
    private var heightConstraint = NSLayoutConstraint()
    private var widthConstraint = NSLayoutConstraint()
    private var optionItems = [MapViewOptionsType.listView, MapViewOptionsType.mapView]
    
    weak var delegate: MapViewSettingsViewDelegate? = nil
    private unowned var filteringSettings: FilteringSettings
    
    init(filteringSettings: FilteringSettings) {
        self.filteringSettings = filteringSettings
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0.0, height: 1)
        layer.shadowRadius = 1.0
        widthConstraint = widthAnchor.constraint(equalToConstant: 40)
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        layer.cornerRadius = 40 / 2
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        backgroundColor = UIColor.appPrimaryColour()
        
        
        addSubview(settingsButton)
        settingsButton.widthAnchor.constraint(equalToConstant: 40 - 6).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: heightConstraint.constant - 6).isActive = true

    }
    
    private func expand() {
        delegate?.wasExpanded()
        
        heightConstraint.constant = 150
        widthConstraint.constant = 260
        setupOptions()
        settingsButton.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.superview!.layoutIfNeeded()
        }) { (_) in
            self.setupAdvancedSettings()
            self.isExpanded = true
        }
    }
    
    func collapse() {
        heightConstraint.constant = 40
        widthConstraint.constant = 40
        settingsButton.setImage(#imageLiteral(resourceName: "Settings"), for: [])
        tableView.removeFromSuperview()
        delegate?.wasCollapsed()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.removeAdvancedSettingsView()
            self.superview!.layoutIfNeeded()
        }) { (_) in
            
            self.isExpanded = false
        }
    }
    
    
    private func setupOptions() {
        addSubview(tableView)
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        tableView.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: 3).isActive = true
        
        DispatchQueue.main.async {
            self.superview!.layoutIfNeeded()
        }
    }
    
    private func setupAdvancedSettings() {
        let advancedSettingsView: UIView = {
           let view = UIView()
            view.backgroundColor = UIColor.clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.alpha = 0
            
            let dividerView: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor.appWhite()
                view.widthAnchor.constraint(equalToConstant: 2).isActive = true
                view.layer.cornerRadius = 1
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            let contentStackView: UIStackView = {
               let stackView = UIStackView()
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.axis = .vertical
                stackView.spacing = 10
                stackView.distribution = .fillEqually
                
                let radiusStackView: UIStackView = {
                   let stackView = UIStackView()
                    stackView.axis = .vertical
                    stackView.spacing = 5
                    
                    let label: UILabel = {
                       let label = UILabel()
                        label.font = UIFont.appPrimary()
                        label.textColor = UIColor.appWhite()
                        let regionRadius = (filteringSettings.regionRadius / 1000).rounded(toPlaces: 1)
                        label.attributedText = createAttributedText(normalText: "Radius: ", highligtedText: "\(regionRadius) km")
                        radiusSliderLabel = label
                        return label
                    }()
                    
                    let slider: UISlider = {
                        let slider = UISlider()
                        slider.maximumValue = Float(5000)
                        slider.minimumValue = Float(1000)
                        slider.tag = 40
                        slider.tintColor = UIColor.appSecondaryColour()
                        slider.value = Float(filteringSettings.regionRadius)
                        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: UIControl.Event.valueChanged)
                        return slider
                    }()
                    
                    stackView.addArrangedSubview(label)
                    stackView.addArrangedSubview(slider)
                    return stackView
                }()
            
                let ageStackView: UIStackView = {
                   let stackView = UIStackView()
                    stackView.axis = .vertical
                    stackView.spacing = 5
                    
                    let label: UILabel = {
                        let label = UILabel()
                        label.font = UIFont.appPrimary()
                        label.textColor = UIColor.appWhite()
                        let pronoun = filteringSettings.age == 1 ? "år": "år"
                        label.attributedText = createAttributedText(normalText: "Fundets alder: ", highligtedText: "\(filteringSettings.age) \(pronoun)")
                        ageSliderLabel = label
                        return label
                    }()
                    
                    let slider: UISlider = {
                        let slider = UISlider()
                        slider.maximumValue = Float(8)
                        slider.minimumValue = Float(1)
                        slider.tag = 50
                        slider.tintColor = UIColor.appSecondaryColour()
                        slider.value = Float(filteringSettings.age)
                        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: UIControl.Event.valueChanged)
                        return slider
                    }()
                    
                    stackView.addArrangedSubview(label)
                    stackView.addArrangedSubview(slider)
                    return stackView
                }()
                
            
                stackView.addArrangedSubview(radiusStackView)
                stackView.addArrangedSubview(ageStackView)
                
                return stackView
                
                
            }()
            
            view.addSubview(dividerView)
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            dividerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            view.addSubview(contentStackView)
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: dividerView.leadingAnchor, constant: -4).isActive = true
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return view
        }()
        
        self.advancedSettingsView = advancedSettingsView
        
        addSubview(self.advancedSettingsView!)
        self.advancedSettingsView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        self.advancedSettingsView?.trailingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 0).isActive = true
        self.advancedSettingsView?.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        self.advancedSettingsView?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.advancedSettingsView?.alpha = 1
        }
    }
    
    private func removeAdvancedSettingsView() {
        advancedSettingsView?.removeFromSuperview()
        advancedSettingsView = nil
    }
    
    private func createAttributedText(normalText: String, highligtedText: String) -> NSAttributedString {
        let first = NSMutableAttributedString(string: normalText, attributes: [NSAttributedString.Key.font: UIFont.appPrimary()])
        first.append(NSAttributedString(string: highligtedText, attributes: [NSAttributedString.Key.font: UIFont.appPrimaryHightlighed()]))
        return first
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
    
    @objc func sliderChangedValue(sender: UISlider) {
        if sender.tag == 40 {
            filteringSettings.regionRadius = CGFloat(sender.value)
            let regionsRadius = CGFloat(sender.value / 1000).rounded(toPlaces: 1)
            radiusSliderLabel?.attributedText = createAttributedText(normalText: "Radius: ", highligtedText: "\(regionsRadius) km")
        } else if sender.tag == 50 {
            filteringSettings.age = Int(sender.value)
            let pronoun = sender.value < 2 ? "år": "år"
            ageSliderLabel?.attributedText = createAttributedText(normalText: "Fundets alder: ", highligtedText: "\(filteringSettings.age) \(pronoun)")
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
            cell.configureCell(icon: #imageLiteral(resourceName: "ListView"))
        case .mapView:
            cell.configureCell(icon: #imageLiteral(resourceName: "MapView"))
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
        view.contentMode = UIView.ContentMode.center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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


fileprivate extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
