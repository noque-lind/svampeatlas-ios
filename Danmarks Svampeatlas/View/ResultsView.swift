//
//  ResultsView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol ResultsViewDelegate: class {
}


class ResultsView: UIView {

    lazy var headerLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appHeader()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    lazy var secondaryLabel: UILabel = {
       let label = UILabel()
    label.font = UIFont.appTitle()
    label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var topView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        view.heightAnchor.constraint(equalToConstant: 110).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(secondaryLabel)
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        return view
    }()
    
    lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.register(ContainedResultCell.self, forCellReuseIdentifier: "resultCell")
        tableView.register(ReloadCell.self, forCellReuseIdentifier: "reloadCell")
        tableView.alpha = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    var results = [temptModel]()
    weak var delegate: ResultsViewDelegate? = nil
    
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setupView() {
        alpha = 0
    }
    
    func showResults() {
        tableView.reloadData()
        
        addSubview(topView)
        topView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        self.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.topView.alpha = 1
            self.tableView.alpha = 1
            self.alpha = 1
        }
        
        if results.count > 0 {
            headerLabel.text = "Vi har \(results.count) forslag"
            secondaryLabel.text = "Vær opmærksom på at disse forslag altid er givet med en vis usikkerhed"
        } else {
            headerLabel.text = "Øv"
            secondaryLabel.text = "Vi har desværre intet forslag til, hvilket art det er. Prøv venligst igen"
        }
    }
    
    func reset() {
        results.removeAll()
        
        topView.alpha = 0
        tableView.alpha = 0
        topView.removeFromSuperview()
        tableView.removeFromSuperview()
        alpha = 0
    }
}

extension ResultsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == results.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reloadCell", for: indexPath) as! ReloadCell
            cell.configureCell(text: "Prøv igen")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ContainedResultCell
//            cell.configureCell(name: results[indexPath.row].identifier, confidence: results[indexPath.row].confidence)
            return cell
        }
        
        
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == results.count {
            return 100
        } else {
        return 78
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == results.count {
//            delegate?.retry()
        } else {
//        delegate?.didSelectSpecies(species: results[indexPath.row])
        }
    }
}
