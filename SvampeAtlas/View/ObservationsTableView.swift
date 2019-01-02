//
//  ObservationsTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 15/09/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit



class ObservationsTableView: GenericTableView, UITableViewDelegate, UITableViewDataSource {
    
    private var observations = [Observation]()
    
    override func setupView() {
        tableView.register(ObservationCell.self, forCellReuseIdentifier: "observationCell")
        tableView.delegate = self
        tableView.dataSource = self
        super.setupView()
    }
    
    func configure(observations: [Observation]) {
        self.observations = observations
        tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "observationCell", for: indexPath) as! ObservationCell
        cell.configure(observation: observations[indexPath.row])
        return cell
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let tableView = tableView.hitTest(convert(point, to: tableView), with: event) {
            return tableView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailsViewController(detailsContent: DetailsContent.observation(observation: observations[indexPath.row], showSpeciesView: automaticallyAdjustHeight ? false: true))
        delegate?.pushVC(vc)
    }
}


