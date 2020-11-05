//
//  MushroomTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit


class AnimatingTableView: UITableView {
    
    private let animating: Bool
    
    init(frame: CGRect, style: UITableView.Style, animating: Bool = true) {
        self.animating = animating
        super.init(frame: frame, style: style)
    }
    
    convenience init(animating: Bool) {
        self.init(frame: CGRect.zero, style: .grouped, animating: animating)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func reloadData() {
        super.reloadData()
        
        if visibleCells.count > 0 && animating {
            
            var delayCounter = 0.0
            for cell in self.visibleCells {
                cell.contentView.alpha = 0
                
                UIView.animate(withDuration: 0.1, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                    cell.contentView.transform = CGAffineTransform.identity
                    cell.contentView.alpha = 1
                }, completion: nil)
                delayCounter = delayCounter + 0.04
            }
        }
    }
}

class AppTableView: UITableView {
    
    private var animating: Bool
    private var spinner = Spinner()
    
    init(animating: Bool, frame: CGRect, style: UITableView.Style) {
        self.animating = animating
        super.init(frame: frame, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func reloadData() {
        super.reloadData()
        if self.visibleCells.count > 0 {
            self.backgroundView = nil
            guard animating == true else {return}
            
            var delayCounter = 0.0
            for cell in self.visibleCells {
                cell.contentView.alpha = 0
                UIView.animate(withDuration: 0.2, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                    cell.contentView.transform = CGAffineTransform.identity
                    cell.contentView.alpha = 1
                }, completion: nil)
                delayCounter = delayCounter + 0.10
            }
            self.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
    }
    
    func showLoader() {
        DispatchQueue.main.async {
            self.backgroundView = UIView(frame: self.frame)
            self.spinner.addTo(view: self.backgroundView!)
            self.spinner.start()
        }
    }
    
    func showError(_ appError: AppError, handler: ((RecoveryAction?) -> ())?) {
        DispatchQueue.main.async {
            let view = ErrorView()
            view.configure(error: appError, handler: handler)
        
            self.backgroundView = view
        }
    }
}
