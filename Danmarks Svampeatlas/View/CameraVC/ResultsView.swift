//
//  ResultsView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 08/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

protocol ResultsViewDelegate: class {
    func retry()
    func mushroomSelected(predictionResult: Prediction, predictionResults: [Prediction])
}

class ResultsView: UIView, UIGestureRecognizerDelegate {

    enum Item {
        case title(title: String, subtitle: String)
        case result(prediction: Prediction)
        case tryAgain
        case creditation
        case lowConfidence
    }
    
    class CellProvider: NSObject, ELTableViewCellProvider {
        typealias CellItem = Item
        
        func cellForItem(_ item: ResultsView.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch item {
            case .title(title: let title, subtitle: let subtitle):
                let cell = tableView.dequeueReusableCell(withIdentifier: ResultsTitleCell.identifier, for: indexPath) as! ResultsTitleCell
                cell.configure(title: title, subtitle: subtitle)
                return cell
            case .result(prediction: let predictionResult):
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
        
        func heightForItem(_ item: ResultsView.Item, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
            switch item {
            case .tryAgain:
                return LoaderCell.height
            case .result, .creditation, .lowConfidence, .title:
                return UITableView.automaticDimension
            }
        }
        
        func registerCells(tableView: UITableView) {
            tableView.register(ContainedResultCell.self, forCellReuseIdentifier: ContainedResultCell.identifier)
            tableView.register(ReloadCell.self, forCellReuseIdentifier: ReloadCell.identifier)
            tableView.register(CreditationCell.self, forCellReuseIdentifier: CreditationCell.identifier)
            tableView.register(CautionCell.self, forCellReuseIdentifier: CautionCell.identifier)
            tableView.register(ResultsTitleCell.self, forCellReuseIdentifier: ResultsTitleCell.identifier)
        }
    }
    
   
    
    private lazy var tableView = ELTableView.build(provider: CellProvider()).then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)
        $0.didSelectItem.handleEvent { [weak delegate, unowned self] item in
            switch item.Item {
            case .tryAgain: delegate?.retry()
            case .result(prediction: let predictionsResult):
                delegate?.mushroomSelected(predictionResult: predictionsResult, predictionResults: self.results)
            default: break
            }
        }
    })
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if tableView.scrollView.contentOffset == CGPoint.zero {
            return false
        } else {
            return true
        }
    }
    
    private var results = [Prediction]()
    private var reliablePrediction: Bool = true
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
    
    func configure(results: [Prediction], reliablePrediction: Bool) {
        self.results = results
        self.reliablePrediction = reliablePrediction
    }
    
    func showResults() {
        self.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if let error = error {
            tableView.setSections(sections: [
                .init(title: nil, state: .error(error: error, handler: nil)),
                .init(title: nil, state: .items(items: [.tryAgain]))
            ])
            self.error = nil
        } else {
            var highestConfidence = 0.0
            results.forEach { (predictionResult) in
                
                if predictionResult.score > highestConfidence {
                    highestConfidence = predictionResult.score * 100
                }
            }
            
            
            var items = results.compactMap({Item.result(prediction: $0)})
            items.append(.creditation)
            
            if highestConfidence < 50.0 {
                items.insert(.lowConfidence, at: 0)
            }
            
            if reliablePrediction {
                tableView.setSections(sections: [
                    .init(title: nil, state: .items(items: [.title(title: NSLocalizedString("resultsView_header_title", comment: ""), subtitle:  NSLocalizedString("resultsView_header_message", comment: ""))])),
                    .init(title: nil, state: .items(items: items)),
                    .init(title: nil, state: .items(items: [.tryAgain]))
                ])
            } else {
                tableView.setSections(sections: [
                    .init(title: nil, state: .items(items: [.title(title: NSLocalizedString("resultsView_unpredictable_title", comment: ""), subtitle:  NSLocalizedString("resultsView_unpredictable_message", comment: ""))])),
                    .init(title: nil, state: .items(items: [.tryAgain])),
                        .init(title: nil, state: .items(items: items)),
                ])
            }
        }
        
        UIView.animate(withDuration: 0.2) {
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
        tableView.alpha = 0
        tableView.removeFromSuperview()
        alpha = 0
    }
}
