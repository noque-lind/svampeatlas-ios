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

struct ObservationSettings {
    enum ObservationAge {
        case before2000
        case after2000
    }

    var radius: Double
    var age: ObservationAge
}


protocol MapViewSettingsViewDelegate {
    func newSearch(settings: ObservationSettings)
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
                ageLabel = nil
            }
        }
    }
    
    private var radiusSliderLabel: UILabel?
    private var ageLabel: UILabel?
    
    private var isExpanded = false
    private var heightConstraint = NSLayoutConstraint()
    private var widthConstraint = NSLayoutConstraint()
    private var optionItems = [MapViewOptionsType.listView, MapViewOptionsType.mapView]
    
    var delegate: MapViewSettingsViewDelegate? = nil
    var observationSettings: ObservationSettings?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) not implemented in mapViewSettingsView")
    }
    
    private func setupView() {
        widthConstraint = widthAnchor.constraint(equalToConstant: 40)
        heightConstraint = heightAnchor.constraint(equalToConstant: 40)
        layer.cornerRadius = 40 / 2
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        backgroundColor = UIColor.appSecondaryColour()
        
        
        addSubview(settingsButton)
        settingsButton.widthAnchor.constraint(equalToConstant: 40 - 6).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: heightConstraint.constant - 6).isActive = true

    }
    
    private func expand() {
        heightConstraint.constant = 150
        widthConstraint.constant = 260
        setupOptions()
        settingsButton.setImage(#imageLiteral(resourceName: "Exit"), for: [])
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
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
                
                let radiusStackView: UIStackView = {
                   let stackView = UIStackView()
                    stackView.axis = .vertical
                    stackView.spacing = 5
                    
                    let label: UILabel = {
                       let label = UILabel()
                        label.font = UIFont.appPrimary()
                        label.textColor = UIColor.appWhite()
                        label.text = "Søgeradius: 0.2 km."
                        radiusSliderLabel = label
                        return label
                    }()
                    
                    let slider: UISlider = {
                        let slider = UISlider()
                        slider.maximumValue = 3000
                        slider.minimumValue = 200
                        slider.tintColor = UIColor.appPrimaryColour()
                        slider.addTarget(self, action: #selector(radiusSliderChanged(sender:)), for: UIControlEvents.valueChanged)
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
                        label.text = "Fundets alder:"
                        ageLabel = label
                        return label
                    }()
                    
                    let segmentedControl: UISegmentedControl = {
                       let segmentedControl = UISegmentedControl()
                        segmentedControl.insertSegment(withTitle: "2 uger", at: 0, animated: false)
                        segmentedControl.insertSegment(withTitle: "3 mdr", at: 1, animated: false)
                        segmentedControl.insertSegment(withTitle: "1 år", at: 2, animated: false)
                        segmentedControl.tintColor = UIColor.appWhite()
                        return segmentedControl
                    }()
                    
                    stackView.addArrangedSubview(label)
                    stackView.addArrangedSubview(segmentedControl)
                    return stackView
                }()
                
                let searchButton: UIButton = {
                   let button = UIButton()
                    button.addTarget(self, action: #selector(searchButtonPressed(sender:)), for: .touchUpInside)
                    button.backgroundColor = UIColor.appPrimaryColour()
                    return button
                }()
                
                stackView.addArrangedSubview(radiusStackView)
                stackView.addArrangedSubview(ageStackView)
                stackView.addArrangedSubview(searchButton)
                
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
}

extension MapViewSettingsView {
    @objc func settingsButtonPressed(sender: UIButton) {
        if isExpanded {
            collapse()
        } else {
             expand()
        }
    }
    
    @objc func searchButtonPressed(sender: UIButton) {
        delegate?.newSearch(settings: observationSettings!)
    }

    @objc func radiusSliderChanged(sender: UISlider) {
        if observationSettings != nil {
            observationSettings?.radius = Double(sender.value / 1000).rounded(toPlaces: 1)
        } else {
            observationSettings = ObservationSettings(radius: Double(sender.value / 1000).rounded(toPlaces: 1), age: ObservationSettings.ObservationAge.after2000)
        }
        radiusSliderLabel?.text = "Søgeradius: \(observationSettings!.radius) km."
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
        view.contentMode = UIViewContentMode.center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
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


fileprivate extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
