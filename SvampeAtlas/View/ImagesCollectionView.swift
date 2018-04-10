//
//  ImagesCollectionView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ImagesCollectionView: UICollectionView {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    public private(set) var maximumHeight: CGFloat!
    public private(set) var minimumHeight: CGFloat!
    private var isExpanded: Bool = true
    
    public func animateToPosition() {
        if heightConstraint.constant != minimumHeight {
        if heightConstraint.constant > (minimumHeight + ((maximumHeight - minimumHeight) / 5) * 4) {
            heightConstraint.constant = self.maximumHeight
            isExpanded = true
        } else {
            if !isExpanded && heightConstraint.constant > minimumHeight + ((maximumHeight - minimumHeight) / 5) {
                heightConstraint.constant = self.maximumHeight
                isExpanded = true
            } else {
            isExpanded = false
            heightConstraint.constant = self.minimumHeight
            }
        }
            collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        maximumHeight = heightConstraint.constant
        minimumHeight = heightConstraint.constant * 0.3
        super.awakeFromNib()
    }
}
