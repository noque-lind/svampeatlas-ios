//
//  ObservationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
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

class ObservationsTableView: UIView {
    
    private lazy var tableView: CustomTableView = {
       let tableView = CustomTableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.appPrimaryColour()
        tableView.alwaysBounceVertical = false
        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        return tableView
    }()
    
    private var observations = [Observation]()
    private let rowHeight: CGFloat = 120
    private let automaticallyAdjustHeight: Bool
    weak var delegate: NavigationDelegate?
    
    init(automaticallyAdjustHeight: Bool) {
        self.automaticallyAdjustHeight = automaticallyAdjustHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let tableView = tableView.hitTest(convert(point, to: tableView), with: event) {
            return tableView
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func configure(observations: [Observation]) {
        if automaticallyAdjustHeight {
            heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(observations.count)).isActive = true
            tableView.panGestureRecognizer.isEnabled = false
        }
        
        self.observations = observations
        tableView.reloadData()
    }
    
    
}

extension ObservationsTableView: UITableViewDelegate, UITableViewDataSource {
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
        let vc = DetailsViewController(detailsContent: DetailsContent.observation(observation: observations[indexPath.row], showSpeciesView: automaticallyAdjustHeight ? false: true))
        delegate?.pushVC(vc)
    }
}


