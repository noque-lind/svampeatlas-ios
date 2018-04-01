//
//  CustomSearchBar.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 01/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol CustomSearchBarDelegate: NSObjectProtocol {
    func shouldExpandSearchBar()
    func shouldCollapseSearchBar()
}

class CustomSearchBar: UITextField {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    lazy var iconView: UIButton = {
       let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: heightConstraint.constant, height: heightConstraint.constant))
        button.backgroundColor = UIColor.appSecondaryColour()
        button.setImage(#imageLiteral(resourceName: "Search"), for: [])
        button.clipsToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 1.5
        button.layer.masksToBounds = false
        button.layer.cornerRadius = heightConstraint.constant / 2
        button.addTarget(self, action: #selector(searchButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    weak var searchBarDelegate: CustomSearchBarDelegate? = nil
    public private(set) var isExpanded: Bool = false
    private var shapeLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        round()
        super.layoutSubviews()
    }
    
    private func setupView() {
        collapsedProperties()
        leftViewMode = .always
        leftView = iconView
        
    }

    
    private func round() {
        let radius = self.frame.height / 2
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
    }
    
    
    override func becomeFirstResponder() -> Bool {
//        searchBarDelegate?.shouldExpandSearchBar()
        super.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        searchBarDelegate?.shouldCollapseSearchBar()
        super.resignFirstResponder()
        return true
    }
}

extension CustomSearchBar {
    @objc func searchButtonPressed(sender: UIButton) {
        if !isExpanded {
            searchBarDelegate?.shouldExpandSearchBar()
        } else {
            searchBarDelegate?.shouldCollapseSearchBar()
        }
    }
    
    func expandedProperties() {
        isExpanded = true
        backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.9)
        iconView.layer.shadowOpacity = 0.0
        layer.mask = shapeLayer
    }
    
    func collapsedProperties() {
        isExpanded = false
        backgroundColor = UIColor.clear
        layer.mask = nil
        iconView.layer.shadowOpacity = 0.4
    }
}
