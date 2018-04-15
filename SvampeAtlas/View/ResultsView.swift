//
//  ResultsView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ResultsView: UIView {

    @IBOutlet weak var tableView: UITableView!
    var results = [temptModel]()
    
    override func awakeFromNib() {
        setupView()
    }
    
    private func setupView() {
        alpha = 0
    }
    
    func showResults() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
}

extension ResultsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultCell
        cell.configureCell(name: results[indexPath.row].identifier, confidence: results[indexPath.row].confidence)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
