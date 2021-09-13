//
//  ActionButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 28/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


class ActionButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let labelWidth = titleLabel?.intrinsicContentSize.width {
            titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            titleLabel?.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .appGreen()
        setImage(#imageLiteral(resourceName: "Glyphs_Checkmark"), for: [])
        layer.shadowOpacity = .shadowOpacity()
        layer.cornerRadius = .cornerRadius()
        layer.shadowOffset = .shadowOffset()
        titleLabel?.font = .appBold()
        titleLabel?.textColor = .appWhite()
        contentEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
        titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
        titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    @available(iOS 13.0, *)
    func configure(text: String, contextDelegate: UIContextMenuInteractionDelegate) {
        setTitle(text, for: [])
        addInteraction(UIContextMenuInteraction(delegate: contextDelegate))
    }
   
    func configure(text: String) {
        setTitle(text, for: [])
    }

}
