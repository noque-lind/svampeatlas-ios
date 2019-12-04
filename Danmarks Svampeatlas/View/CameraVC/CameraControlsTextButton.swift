//
//  CameraControlsTextButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 01/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CameraControlsTextButton: UIButton {
    
    enum TextState: String {
           case noPhoto = "Intet billede"
           case usePhoto = "Brug billede"
       }
    
    var pressed: (() -> ())?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func setupView() {
        titleLabel?.textAlignment = .center
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(UIColor.appWhite(), for: .normal)
        setTitleColor(UIColor.darkGray, for: .highlighted)
        titleLabel?.font = UIFont.appPrimary()
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    @objc private func onPress() {
        pressed?()
    }
    
    func setState(state: TextState) {
        setTitle(state.rawValue, for: [])
    }
}
