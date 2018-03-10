//
//  MushroomTableView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 10/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomTableView: UITableView {
    override func reloadData() {
        super.reloadData()
        var delayCounter = 0.0
        for cell in self.visibleCells {
            cell.contentView.alpha = 0
            UIView.animate(withDuration: 0.2, delay: TimeInterval(delayCounter), options: .curveEaseIn, animations: {
                cell.contentView.transform = CGAffineTransform.identity
                cell.contentView.alpha = 1
            }, completion: nil)
            delayCounter = delayCounter + 0.10
        }
    }
}
