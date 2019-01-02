//
//  ELGenericTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 16/11/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        } else {
            return nil
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return false
        } else {
            return true
        }
    }
}

class GenericTableView: UIView {
    
    internal lazy var tableView: CustomTableView = {
        let tableView = CustomTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.appSecondaryColour()
        tableView.alwaysBounceVertical = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.panGestureRecognizer.isEnabled = false
        return tableView
    }()
    
    internal var heightConstraint = NSLayoutConstraint()
    weak var delegate: NavigationDelegate?
    internal var automaticallyAdjustHeight: Bool
    
    init(automaticallyAdjustHeight: Bool = true) {
        self.automaticallyAdjustHeight = automaticallyAdjustHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    
    internal func setupView() {
        backgroundColor = UIColor.clear
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if automaticallyAdjustHeight {
            heightConstraint = heightAnchor.constraint(equalToConstant: 0)
            heightConstraint.isActive = true
            tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: [], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard automaticallyAdjustHeight == true else {return}
        if keyPath == #keyPath(UITableView.contentSize) {
            heightConstraint.isActive = false
            heightConstraint.constant = tableView.contentSize.height
            heightConstraint.isActive = true
        }
    }
}


