//
//  CalloutView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ClusterPinCalloutView: UIView {
    
    private lazy var observationsTableView: ObservationsTableView = {
       let tableView = ObservationsTableView(automaticallyAdjustHeight: false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.didSelectItem = self.showObservation
        return tableView
    }()
    
    private var observations = [Observation]()
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    private var rowHeight: CGFloat = 120
    var showObservation: ((_ observation: Observation) -> ())?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let observationsTableView = observationsTableView.hitTest(convert(point, to: observationsTableView), with: event) {
            return observationsTableView
        }
        return nil
    }
   
    init(showObservation: ((_ observation: Observation) -> ())?) {
        self.showObservation = showObservation
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
        addSubview(observationsTableView)
        observationsTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        observationsTableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        observationsTableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        observationsTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
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
            self.observationsTableView.tableViewState = .Items(self.observations)
            UIView.animate(withDuration: 0.2, animations: {
                self.observationsTableView.alpha = 1
            }, completion: nil)
        }
    }
    
    func hide(superView: UIView, animated: Bool, completion: @escaping () -> ()) {
        observationsTableView.tableViewState = .Empty
        
        if animated {
            widthConstraint.constant = superView.frame.width
            heightConstraint.constant = superView.frame.height
            
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.superview!.layoutIfNeeded()
                self.alpha = 0
            }) { (_) in
                completion()
            }
        } else {
            completion()
        }
    }
    
    deinit {
        print("CluserCalloutViewDeinit")
    }
}
