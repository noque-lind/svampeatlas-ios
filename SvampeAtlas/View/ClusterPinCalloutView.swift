//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ClusterPinCalloutView: UIView {
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.alpha = 0
        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        return tableView
    }()
    
    private var observations = [Observation]()
    

    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.appPrimaryColour()
        self.clipsToBounds = true
        self.alpha = 0
        

        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func setupConstraints(superView: UIView) {
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: superView.frame.width)
        heightConstraint = heightAnchor.constraint(equalToConstant: superView.frame.height)
        layer.cornerRadius = superView.frame.height / 2
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        superView.layoutIfNeeded()
    }
    
    

    func show() {
        heightConstraint.constant = 300
        widthConstraint.constant = 250
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.superview!.layoutIfNeeded()
            self.alpha = 1
        }) { (_) in
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.alpha = 1
            }, completion: nil)
        }
    }
    
    func hide(superView: UIView,animated: Bool) {
        if animated {
            widthConstraint.constant = superView.frame.width
            heightConstraint.constant = superView.frame.height
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.superview!.layoutIfNeeded()
                self.alpha = 0
            }) { (_) in
                self.reset()
            }
        } else {
            alpha = 0
            reset()
        }
    }
    
    func configureCalloutView(observationPins: [ObservationPin]) {
        for observationPin in observationPins {
            observations.append(observationPin.observation)
        }
    }
    
    
    private func reset() {
        DispatchQueue.main.async {
            self.widthConstraint.isActive = false
            self.heightConstraint.isActive = false
            
            if let superView = self.superview {
                superView.layoutIfNeeded()
            }
            self.removeFromSuperview()
        }
    }
}

extension ClusterPinCalloutView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath) as! ObservationCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
