//
//  IconButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 18/10/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class IconButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
        required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.do({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            let size: CGFloat = 40
            $0.widthAnchor.constraint(equalToConstant: size).isActive = true
            $0.heightAnchor.constraint(equalToConstant: size).isActive = true
            let inset = (size / 2) - 14
            $0.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            $0.setImage(#imageLiteral(resourceName: "Glyphs_Settings"), for: [])
            $0.layer.cornerRadius = CGFloat.cornerRadius()
        })
    }
}
