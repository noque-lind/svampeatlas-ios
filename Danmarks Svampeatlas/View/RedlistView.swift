//
//  RedlistView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class RedlistView: UIView {

    private lazy var smallLabel = UILabel().then({
        $0.font = .appPrimary(customSize: 12)
        $0.textColor = .appWhite()
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
    })
    
    private lazy var statusView = UIView().then({ (view) in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .cornerRadius()
        view.addSubview(smallLabel)
        smallLabel.do({
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        })
    })
    
    private var label = UILabel().then({
        $0.font = .appPrimary(customSize: 12)
        $0.textColor = .appWhite()
    })
    
    init(detailed: Bool = false) {
        super.init(frame: CGRect.zero)
        setupView(detailed: detailed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView(detailed: Bool) {
        let stackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.spacing = 8
            $0.addArrangedSubview(statusView)
            $0.addArrangedSubview(label)
        })
        
        addSubview(stackView)
        ELSnap.snapView(stackView, toSuperview: self)
    }
    
    func configure(redlistStatus: String) {
        smallLabel.text = redlistStatus
        switch redlistStatus {
        case "LC", "NT":
            statusView.backgroundColor = UIColor.appGreen()
                label.text = NSLocalizedString("redlistView_lcnt", comment: "")
        case "CR", "EN":
            statusView.backgroundColor = UIColor.appRed()
            label.text = NSLocalizedString("redlistView_cren", comment: "")
        case "VU":
            statusView.backgroundColor = UIColor.appYellow()
            label.text = NSLocalizedString("redlistView_vu", comment: "")
        
        case "DD":
            statusView.backgroundColor = UIColor.gray
            label.text = NSLocalizedString("redlistView_dd", comment: "")
        default:
            statusView.backgroundColor = UIColor.clear
        }
    }
}
