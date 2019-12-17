//
//  CustomSearchBar.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 01/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol CustomSearchBarDelegate: NSObjectProtocol {
    func newSearchEntry(entry: String)
    func clearedSearchEntry()
}

class SearchBar: UITextField {
    
    var leadingConstraint = NSLayoutConstraint()
    private var widthConstraint = NSLayoutConstraint()
    
    private lazy var iconView: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.appSecondaryColour()
        button.setImage(#imageLiteral(resourceName: "Glyphs_Search"), for: [])
        button.clipsToBounds = false
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowRadius = 1.5
        button.layer.shadowOpacity = Float.shadowOpacity()
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(searchButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    private var progressBarView: ProgressBarView?
    private var recentSearch: String?
    weak var searchBarDelegate: CustomSearchBarDelegate? = nil
    public private(set) var isExpanded: Bool = false
    private var shapeLayer = CAShapeLayer()

    
    init(radius: CGFloat = 50, trailingConstant: CGFloat = 8) {
        super.init(frame: CGRect.zero)
        setupView()
        heightAnchor.constraint(equalToConstant: radius).isActive = true
        iconView.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        widthConstraint = widthAnchor.constraint(equalToConstant: radius + 8)
        iconView.layer.cornerRadius = radius / 2
        layer.cornerRadius = radius / 2
        layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
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
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: bounds.height, height: bounds.height)
    }
    
    private func setupView() {
        isHidden = true
        autocorrectionType = .no
        
        backgroundColor = UIColor.clear
        returnKeyType = .search
        iconView.layer.shadowOpacity = 0.4
        
        leftViewMode = .always
        leftView = iconView
        
        font = UIFont.appPrimaryHightlighed()
        textColor = UIColor.appWhite()
        configurePlaceholder("Søg efter en art her ...")
        
        clearButtonMode = .whileEditing
        tintColor = UIColor.appWhite()
        
        self.addTarget(self, action: #selector(returnButtonPressed(sender:)), for: UIControl.Event.editingDidEndOnExit)
        self.addTarget(self, action: #selector(editingChanged(sender:)), for: UIControl.Event.editingChanged)
    }
    
    func configurePlaceholder(_ placeholder: String) {
        self.placeholder = nil
          attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font: UIFont.appPrimary(), NSAttributedString.Key.foregroundColor: UIColor.appWhite().withAlphaComponent(0.8)])
    }
    
  
    
    func setHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.isHidden = hidden
        }
    }
}

extension SearchBar {
    @objc func editingChanged(sender: UITextField) {
        guard let text = sender.text, text != "" else {progressBarView?.reset(); searchBarDelegate?.clearedSearchEntry(); return}
        
        if text.last != " " && text.count > 3 {
            beginLoadTimer()
        } else {
            progressBarView?.reset()
        }
    }
    
    @objc private func returnButtonPressed(sender: UIButton) {
        progressBarView?.reset()
        guard let text = text, text != "" && text != " " else {return}
        completedLoading()
    }
    
    @objc func searchButtonPressed(sender: UIButton) {
        if !isExpanded {
            iconView.setImage(#imageLiteral(resourceName: "Glyphs_Cancel"), for: [])
            expand()
            self.becomeFirstResponder()
        } else {
            if iconView.image(for: []) != #imageLiteral(resourceName: "Glyphs_Search") {
                collapse()
                searchBarDelegate?.clearedSearchEntry()
            }
        }
    }
    
    func expand() {
        if !isExpanded {
            widthConstraint.isActive = false
            leadingConstraint.isActive = true
            clipsToBounds = true
            UIView.animate(withDuration: 0.2) {
                self.superview?.layoutIfNeeded()
                self.backgroundColor = UIColor.appPrimaryColour().withAlphaComponent(0.9)
                self.textColor = UIColor.appWhite().withAlphaComponent(1.0)
                self.attributedPlaceholder = NSAttributedString(string: "Søg efter en art her...", attributes: [NSAttributedString.Key.font: UIFont.appPrimary(), NSAttributedString.Key.foregroundColor: UIColor.appWhite().withAlphaComponent(0.8)])
            }
            isExpanded = true
        }
    }
    
    func collapse() {
        if isExpanded {
            clipsToBounds = false
            leadingConstraint.isActive = false
            widthConstraint.isActive = true
            
            progressBarView?.reset()
            progressBarView?.removeFromSuperview()
            progressBarView = nil
            
            UIView.animate(withDuration: 0.2) {
                self.superview?.layoutIfNeeded()
            }
            
            iconView.setImage(#imageLiteral(resourceName: "Glyphs_Search"), for: [])
            self.backgroundColor = UIColor.clear
            iconView.layer.shadowOpacity = 0.4
            layer.mask = nil
            clipsToBounds = false
            textColor = UIColor.appWhite().withAlphaComponent(0.0)
            attributedPlaceholder = NSAttributedString(string: "Søg efter en art her...", attributes: [NSAttributedString.Key.font: UIFont.appPrimary(), NSAttributedString.Key.foregroundColor: UIColor.appWhite().withAlphaComponent(0.0)])
            _ = self.resignFirstResponder()
            isExpanded = false
        }
    }
    
    private func beginLoadTimer() {
        if progressBarView != nil {
            progressBarView?.startLoading()
        } else {
            progressBarView = ProgressBarView()
            progressBarView?.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(progressBarView!, belowSubview: iconView)
            progressBarView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            progressBarView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            progressBarView?.heightAnchor.constraint(equalToConstant: 2).isActive = true
            progressBarView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            progressBarView?.delegate = self
            progressBarView?.startLoading()
        }
    }
}

extension SearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension SearchBar: ProgressBarViewDelegate {
    func completedLoading() {
        guard let entry = text, entry != recentSearch else {return}
        searchBarDelegate?.newSearchEntry(entry: entry)
        recentSearch = entry
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}


