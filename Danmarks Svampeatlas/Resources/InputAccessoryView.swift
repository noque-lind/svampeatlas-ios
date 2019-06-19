//
//  InputAccessoryView.swift
//  Arne
//
//  Created by Emil Lind on 22/01/2018.
//  Copyright © 2018 Emil Lind. All rights reserved.
//

import UIKit

class InputAccessoryView: UIView {

    let responderObject: UIResponder!
    
    init(frame: CGRect, withTitle: String, itemToResign: UIResponder) {
        responderObject = itemToResign
        super.init(frame: frame)
        setupView(withTitle: withTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(withTitle: String) {
        backgroundColor = UIColor.appGreen()
        let button = UIButton(frame: self.frame)
        self.addSubview(button)
        button.setTitle(withTitle, for: [])
        button.titleLabel?.font = UIFont.appTitle()
        button.setTitleColor(UIColor.appWhite(), for: [])
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(resign), for: .touchUpInside)
    }
    
    @objc func resign() {
        responderObject.resignFirstResponder()
    }
    
}
