//
//  MushroomDetailsScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MushroomDetailsScrollView: UIScrollView {

    public func setupInsets(collectionViewHeight: CGFloat) {
        self.contentInset = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
        self.scrollIndicatorInsets = UIEdgeInsets(top: collectionViewHeight, left: 0, bottom: 0, right: 0)
    }
    
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        self.contentSize = CGSize(width: self.frame.width, height: frame.size.height * 4)
        let label = UILabel(frame: CGRect.init(x: 0, y: 600, width: 300, height: 300))
        label.text = "HAHAHAHAA"
        addSubview(label)
    }
}
