//
//  MushroomTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

enum LocationBackgroundType {
    case Map
    case List
}

class MushroomTableView: UITableView {
    public var categoryType: Category!
    
    override func reloadData() {
        super.reloadData()
        if self.visibleCells.count > 0 {
            self.backgroundView = nil
            var delayCounter = 0.0
            for cell in self.visibleCells {
                cell.contentView.alpha = 0
                UIView.animate(withDuration: 0.2, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                    cell.contentView.transform = CGAffineTransform.identity
                    cell.contentView.alpha = 1
                }, completion: nil)
                delayCounter = delayCounter + 0.10
            }
        } else {
            guard let categoryType = categoryType else {return}
            switch categoryType {
            case .offline:
                self.backgroundView = OfflineBackground(frame: self.frame)
            case .local:
                self.backgroundView = LocationBackground(frame: self.frame)
            case .favorites:
                self.backgroundView = FavoritesBackground(frame: self.frame)
            default:
                print("HAHAAHA")
            }
//             Should show a screen depending on the categoryType
        }
        
    }
    
    func showLoader() {
        self.backgroundView = UIView(frame: self.frame)
        self.backgroundView?.controlActivityIndicator(wantRunning: true)
    }
    
}
