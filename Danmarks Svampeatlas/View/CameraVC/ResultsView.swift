//
//  ResultsView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit


protocol ResultsViewDelegate: class {
    func retry()
    func mushroomSelected(predictionResult: PredictionResult, predictionResults: [PredictionResult])
}

class ResultsView: UIView {

    private lazy var headerLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appTitle()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var secondaryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var topView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        let stackView: UIStackView = {
            let view = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addArrangedSubview(headerLabel)
            view.addArrangedSubview(secondaryLabel)
            view.distribution = .fillProportionally
            return view
        }()
        
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return view
    }()
    
    private lazy var tableView: AppTableView = {
       let tableView = AppTableView(animating: false, frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.register(ContainedResultCell.self, forCellReuseIdentifier: "resultCell")
        tableView.register(ReloadCell.self, forCellReuseIdentifier: "reloadCell")
        tableView.alpha = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        return tableView
    }()
    
    private var results = [PredictionResult]()
    weak var delegate: ResultsViewDelegate? = nil
    private var error: AppError?
    
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
    
    func configure(results: [PredictionResult]) {
        self.results = results
        
        if results.count > 0 {
            headerLabel.text = "Vi har \(results.count) forslag til dig"
            secondaryLabel.text = "Bemærk at disse forslag er vejledende og aldrig må stå alene, hvis du ønsker at spise de svampe du har fundet."
            secondaryLabel.textColor = UIColor.red
        } else {
            headerLabel.text = "Øv"
            secondaryLabel.text = "Vi har desværre ingen forslag til dig. Prøv igen, evt. fra en anden vinkel."
            secondaryLabel.textColor = UIColor.appWhite()
        }
    }
    
    func showResults() {
        addSubview(topView)
        topView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        self.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if let error = error {
            tableView.showError(error, handler: nil)
            self.error = nil
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.topView.alpha = 1
            self.tableView.alpha = 1
            self.alpha = 1
        }
    }
    
    func configureError(error: AppError) {
        self.error = error
    }
    
    func reset() {
        results.removeAll()
        tableView.reloadData()
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
                cell.accessoryType = .disclosureIndicator
            let result = results[indexPath.row]
            cell.configureCell(mushroom: result.mushroom, confidence: result.score)
            return cell
        }
        
        
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == results.count {
            return 120
        } else {
        return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == results.count {
            delegate?.retry()
        } else {
            delegate?.mushroomSelected(predictionResult: results[indexPath.row] ,predictionResults: results)
        }
    }
}
