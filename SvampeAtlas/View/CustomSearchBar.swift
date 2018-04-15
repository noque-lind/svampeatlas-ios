//
//  CustomSearchBar.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 01/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol CustomSearchBarDelegate: NSObjectProtocol {
    func shouldExpandSearchBar(animationDuration: TimeInterval)
    func shouldCollapseSearchBar(animationDuration: TimeInterval)
    func newSearchEntry(entry: String)
    func clearedSearchEntry()
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
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftViewWidth = leftView?.frame.size.width else {return bounds}
        let rect = CGRect(x: leftViewWidth + 8, y: 0, width: bounds.width - leftViewWidth - 8, height: bounds.height)
        super.textRect(forBounds: rect)
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftViewWidth = leftView?.frame.size.width else {return bounds}
        let rect = CGRect(x: leftViewWidth + 8, y: 0, width: bounds.width - leftViewWidth - 8, height: bounds.height)
        super.textRect(forBounds: rect)
        return rect
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        
        iconView.layer.shadowOpacity = 0.4
        layer.mask = nil
        
        leftViewMode = .always
        leftView = iconView
        
        font = UIFont.appPrimary()
        textColor = UIColor.appWhite()
        attributedPlaceholder = NSAttributedString(string: "Søg efter en art her...", attributes: [NSAttributedStringKey.font: UIFont.appPrimary(), NSAttributedStringKey.foregroundColor: UIColor.appWhite().withAlphaComponent(0.8)])
        placeholder = "Søg efter en art her..."
        
        clearButtonMode = .always
        tintColor = UIColor.appWhite()
        
        
        
        
        self.addTarget(self, action: #selector(editingChanged(sender:)), for: UIControlEvents.editingChanged)
    }
    
    
    private func round() {
        let radius = self.frame.height / 2
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
    }
}

extension CustomSearchBar {
    @objc func editingChanged(sender: UITextField) {
        guard let entry = sender.text, entry != "" else {searchBarDelegate?.clearedSearchEntry(); return}
        searchBarDelegate?.newSearchEntry(entry: entry)
    }
    
    @objc func searchButtonPressed(sender: UIButton) {
        if !isExpanded {
            iconView.setImage(#imageLiteral(resourceName: "Exit"), for: [])
            expand()
            self.becomeFirstResponder()
        } else {
            if iconView.image(for: []) != #imageLiteral(resourceName: "Search") {
                collapse()
            }
        }
    }
    
    func expand() {
        if !isHidden && !isExpanded {
            searchBarDelegate?.shouldExpandSearchBar(animationDuration: 0.2)
            
            iconView.layer.shadowOpacity = 0.0
            self.layer.mask = self.shapeLayer
           
            
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.9)
                 self.textColor = UIColor.appWhite().withAlphaComponent(1.0)
                self.attributedPlaceholder = NSAttributedString(string: "Søg efter en art her...", attributes: [NSAttributedStringKey.font: UIFont.appPrimary(), NSAttributedStringKey.foregroundColor: UIColor.appWhite().withAlphaComponent(0.8)])
            }
            isExpanded = true
        }
    }
    
    func collapse() {
        if isExpanded {
            searchBarDelegate?.shouldCollapseSearchBar(animationDuration: 0.2)
            iconView.setImage(#imageLiteral(resourceName: "Search"), for: [])
            self.backgroundColor = UIColor.clear
            iconView.layer.shadowOpacity = 0.4
            layer.mask = nil
            textColor = UIColor.appWhite().withAlphaComponent(0.0)
            attributedPlaceholder = NSAttributedString(string: "Søg efter en art her...", attributes: [NSAttributedStringKey.font: UIFont.appPrimary(), NSAttributedStringKey.foregroundColor: UIColor.appWhite().withAlphaComponent(0.0)])
            _ = self.resignFirstResponder()
            isExpanded = false
        }
    }
}
