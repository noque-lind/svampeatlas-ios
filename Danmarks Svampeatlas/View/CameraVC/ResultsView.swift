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

class ResultsTableView: ELTableViewOld<ResultsTableView.Item> {
    
    enum Item {
        case result(predictionResult: PredictionResult)
        case tryAgain
        case creditation
        case lowConfidence
    }
    
    var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    override init() {
        super.init()
        register(cellClass: ContainedResultCell.self, forCellReuseIdentifier: ContainedResultCell.identifier)
        register(cellClass: ReloadCell.self, forCellReuseIdentifier: ReloadCell.identifier)
        register(cellClass: CreditationCell.self, forCellReuseIdentifier: CreditationCell.identifier)
        register(cellClass: CautionCell.self, forCellReuseIdentifier: CautionCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func cellForItem(_ item: ResultsTableView.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .result(predictionResult: let predictionResult):
            let cell = tableView.dequeueReusableCell(withIdentifier: ContainedResultCell.identifier, for: indexPath) as! ContainedResultCell
            cell.configureCell(mushroom: predictionResult.mushroom)
            return cell
            
        case .tryAgain:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReloadCell.identifier, for: indexPath) as! ReloadCell
            cell.configureCell(type: .tryAgain)
            return cell
        case .creditation:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreditationCell.identifier, for: indexPath) as! CreditationCell
            cell.configureCell(creditation: .AI)
            return cell
        case .lowConfidence:
            let cell = tableView.dequeueReusableCell(withIdentifier: CautionCell.identifier, for: indexPath) as! CautionCell
            cell.configureCell(type: .lowConfidence)
            return cell
        }
    }
    
    override func heightForItem(_ item: ResultsTableView.Item) -> CGFloat {
        switch item {
        case .tryAgain:
            return LoaderCell.height
        case .result, .creditation, .lowConfidence:
            return UITableView.automaticDimension
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}

class ResultsView: UIView, UIGestureRecognizerDelegate {

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
    
    private lazy var tableView: ResultsTableView = {
        let tableView = ResultsTableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.didSelectItem = { [weak delegate, unowned self] item, _ in
            switch item {
            case .tryAgain: delegate?.retry()
            case .result(predictionResult: let predictionsResult):
                delegate?.mushroomSelected(predictionResult: predictionsResult, predictionResults: self.results)
            default: break
            }
        }

        return tableView
    }()
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer === tableView.panGestureRecognizer {
//            print("IT IS")
//            return true
//        } else {
//            return false
//        }
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(tableView.scrollView.contentOffset)
        if tableView.scrollView.contentOffset == CGPoint.zero {
            return false
        } else {
            return true
        }
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer === tableView.panGestureRecognizer {
//            print("IT IS")
//            return true
//        } else {
//            return true
//        }
//    }
    
    private var results = [PredictionResult]()
    weak var delegate: ResultsViewDelegate?
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
            headerLabel.text = String.localizedStringWithFormat(NSLocalizedString("resultsView_header_title", comment: ""), results.count)
            secondaryLabel.text = NSLocalizedString("resultsView_header_message", comment: "")
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
            tableView.setSections(sections: [.init(title: nil, state: .error(error: error, handler: nil))])
            self.error = nil
        } else {
            var highestConfidence = 0.0
            results.forEach { (predictionResult) in
                
                if predictionResult.score > highestConfidence {
                    highestConfidence = predictionResult.score * 100
                }
            }
            
            var items = results.compactMap({ResultsTableView.Item.result(predictionResult: $0)})
            items.append(.creditation)
            items.append(.tryAgain)
            
            if highestConfidence < 50.0 {
                items.insert(.lowConfidence, at: 0)
            }
            
            tableView.setSections(sections: [.init(title: nil, state: .items(items: items))])
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
        tableView.setSections(sections: [])
        topView.alpha = 0
        tableView.alpha = 0
        topView.removeFromSuperview()
        tableView.removeFromSuperview()
        alpha = 0
    }
}
