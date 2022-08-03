//
// Created by Emil Møller Lind on 03/08/2022.
// Copyright (c) 2022 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import UIKit
import Then
import ELKit

class LocalitySettingsModal: UIViewController {

    private lazy var textLabel = AutoLabel().then({
        $0.font = .appPrimary()
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.text = NSLocalizedString("settings_locality_message", comment: "")
        $0.numberOfLines = 0
//        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private lazy var locationLock: UISwitch = {
       let view = UISwitch()
        view.tag = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = UIColor.appThird()
        view.tintColor = UIColor.appPrimaryColour()
        view.addTarget(self, action: #selector(switchValueSet), for: .valueChanged)
        return view
    }()
    
    private lazy var localityLock: UISwitch = {
       let view = UISwitch()
        view.tag = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTintColor = UIColor.appThird()
        view.tintColor = UIColor.appPrimaryColour()
        view.addTarget(self, action: #selector(switchValueSet), for: .valueChanged)
        return view
    }()
    
    var localityLockedSet: ((Bool) -> ())?
    var locationLockedSet: ((Bool) -> ())?
    
    init(locationLocked: Bool, localityLocked: Bool) {
        super.init(nibName: nil, bundle: nil)
        locationLock.isOn = locationLocked
        localityLock.isOn = localityLocked
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    
    private func setupView() {
        view.backgroundColor = .appPrimaryColour()
        func createSwitchStackView(title: String, switcher: UISwitch) -> UIStackView {
            let label = AutoLabel().then({
                $0.font = UIFont.appPrimary()
                $0.numberOfLines = 0
                $0.textColor = UIColor.appWhite()
                $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                $0.setContentCompressionResistancePriority(.required, for: .vertical)
                $0.text = title
            })

            return UIStackView().then({
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.axis = .horizontal
                $0.spacing = 16
                $0.distribution = .fill
                $0.alignment = .center
                $0.clipsToBounds = false
                $0.addArrangedSubview(label)
                $0.addArrangedSubview(switcher)
            })
        }
        
        let stackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .vertical
            $0.spacing = 16
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.addArrangedSubview(textLabel)
            $0.addArrangedSubview(UIView().then({
                $0.heightAnchor.constraint(equalToConstant: 1).isActive = true
                $0.backgroundColor = .black.withAlphaComponent(0.3)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }))
            $0.addArrangedSubview(createSwitchStackView(title: NSLocalizedString("settings_remember_location", comment: ""), switcher: locationLock))
            $0.addArrangedSubview(createSwitchStackView(title: NSLocalizedString("settings_remember_locality", comment: ""), switcher: localityLock))
        })
        
        view.do({
            $0.addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: $0.topAnchor, constant: 32).isActive = true
            stackView.trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: -16).isActive = true
            stackView.leadingAnchor.constraint(equalTo: $0.leadingAnchor, constant: 16).isActive = true
            stackView.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: -32).isActive = true
        })
     
            viewDidLayoutSubviews()
    }
    
    @objc private func switchValueSet(view: UISwitch) {
        if (view.tag == 0) {
            locationLockedSet?(view.isOn)
        } else if (view.tag == 1) {
            localityLockedSet?(view.isOn)
        }
    }

}
