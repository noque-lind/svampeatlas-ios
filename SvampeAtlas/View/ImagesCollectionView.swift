//
//  ImagesCollectionView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ImagesCollectionView: UICollectionView {

    private var heightConstraint: NSLayoutConstraint!
    private var defaultHeight: CGFloat!
    private var navigationBarHeight: CGFloat!
    private var isExpanded: Bool = true
    
    private var images = [Images]()
    
    

//    public func animateToPosition() {
//        if heightConstraint.constant != minimumHeight {
//        if heightConstraint.constant > (minimumHeight + ((maximumHeight - minimumHeight) / 5) * 4) {
//            heightConstraint.constant = self.maximumHeight
//            isExpanded = true
//        } else {
//            if !isExpanded && heightConstraint.constant > minimumHeight + ((maximumHeight - minimumHeight) / 5) {
//                heightConstraint.constant = self.maximumHeight
//                isExpanded = true
//            } else {
//            isExpanded = false
//            heightConstraint.constant = self.minimumHeight
//            }
//        }
//            collectionViewLayout.invalidateLayout()
//        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
////            self.superview?.layoutIfNeeded()
//        }, completion: nil)
//        }
//    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        delegate = self
        dataSource = self
        register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
    }
    
    func configure(images: [Images]) {
        self.images = images
        reloadData()
    }
    
    func setupHeightConstraint(defaultHeight: CGFloat, navigationBarHeight: CGFloat) {
        heightConstraint = heightAnchor.constraint(equalToConstant: defaultHeight)
        heightConstraint.isActive = true
        self.defaultHeight = defaultHeight
        self.navigationBarHeight = navigationBarHeight
    }
    
    func configureHeightConstraint(deltaValue value: CGFloat) {
        heightConstraint.constant = defaultHeight - value
        
        let percentValue = 1 - ((heightConstraint.constant - navigationBarHeight) / (defaultHeight - navigationBarHeight))
        print(percentValue)
    }
}

extension ImagesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {fatalError("Failed to deque imageCell")}
        cell.configureCell(url: images[indexPath.row].uri, photoAuthor: images[indexPath.row].photographer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}
