//
//  OfflineBackground.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 13/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class OfflineBackground: UIView {

    var contentStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let label = UILabel()
        label.text = "Du har ikke downloaded nogle svampe til offline brug, vil du downloade?"
        label.numberOfLines = 0
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
        
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Download", for: [])
        button.setTitleColor(UIColor.appThirdColour(), for: [])
        stackView.addArrangedSubview(button)
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
