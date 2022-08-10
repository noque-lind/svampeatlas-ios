//
//  CameraControlsTextButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 01/12/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CameraControlsTextButton: UIButton {
    
    enum TextState {
           case noPhoto
           case usePhoto
        
        var description: String {
            switch self {
            case .noPhoto: return NSLocalizedString("cameraControlTextButton_noPhoto", comment: "")
            case .usePhoto: return NSLocalizedString("cameraControlTextButton_usePhoto", comment: "")
            }
        }
       }
    
    var pressed: (() -> Void)?
    
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
        setTitle(state.description, for: [])
    }
}
