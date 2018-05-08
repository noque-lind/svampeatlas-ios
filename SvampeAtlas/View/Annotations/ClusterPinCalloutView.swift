//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ClusterPinCalloutView: UIView {
    
    private lazy var tableView: CustomTableView = {
       let tableView = CustomTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.alpha = 0
        tableView.alwaysBounceVertical = false
        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        return tableView
    }()
    
    private var observations = [Observation]()
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    private var rowHeight: CGFloat = 100
    weak var delegate: MapViewDelegate? = nil
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let tableView = tableView.hitTest(convert(point, to: tableView), with: event) {
            return tableView
        }
        return nil
    }
    
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
    
    func configure(superView: UIView, observations: [Observation]) {
        self.observations = observations

        widthConstraint = widthAnchor.constraint(equalToConstant: superView.frame.width)
        heightConstraint = heightAnchor.constraint(equalToConstant: super.frame.height)
        
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        
        layer.cornerRadius = superView.frame.height / 2
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        superView.layoutIfNeeded()
    }

    
    func show() {
        widthConstraint.constant = 300
        
        if observations.count >= 4 {
           heightConstraint.constant = rowHeight * 4
        } else {
            heightConstraint.constant = rowHeight * CGFloat(observations.count)
        }
        
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
        observations.removeAll()
        tableView.reloadData()
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
    
   private func reset() {
        DispatchQueue.main.async {
            self.widthConstraint.isActive = false
            self.heightConstraint.isActive = false
            self.tableView.alpha = 0
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
        cell.configure(observation: observations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.shouldShowObservationDetails(observation: observations[indexPath.row])
    }
}

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
