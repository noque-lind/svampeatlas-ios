//
//  CategoryView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol CategoryViewDelegate: NSObjectProtocol {
    func newCategorySelected(category: Category)
}

enum Category: String {
    case offline = "Offline"
    case local = "I nærheden"
    case favorites = "Mine favoritter"
    case rare = "Årstidens"
}

class CategoryView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: CategoryViewDelegate?
    var items = [Category.offline, Category.local, Category.favorites, Category.rare]
    private var selectedItem: Category!
    
    lazy var selectorViewWidthConstraint = NSLayoutConstraint()
    lazy var selectorViewCenterXConstraint = NSLayoutConstraint()
    lazy var selectorView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 3).isActive = true
        view.backgroundColor = UIColor.appThirdColour()
        return view
    }()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        let path = UIBezierPath(roundedRect: selectorView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 3.0, height: 3.0))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        selectorView.layer.mask = mask
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(selectorView)
        selectorViewWidthConstraint = selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (1.0/CGFloat(items.count))/2)
        selectorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectorViewWidthConstraint.isActive = true
        backgroundColor = UIColor.appPrimaryColour()
    }
    
    
    func moveSelector(toCell cell: UICollectionViewCell) {
        selectorViewCenterXConstraint.isActive = false
        selectorViewCenterXConstraint = selectorView.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
        selectorViewCenterXConstraint.isActive = true
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    public func firstSelect() {
        collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .left)
        collectionView(collectionView, didSelectItemAt: IndexPath.init(row: 0, section: 0))
    }
}

extension CategoryView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {fatalError("Could not deque categoryCell")}
        cell.configureCell(title: items[indexPath.row].rawValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / CGFloat(items.count), height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedItem != items[indexPath.row] {
            return true
        } else {
            return false
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = items[indexPath.row]
        delegate?.newCategorySelected(category: items[indexPath.row])
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        moveSelector(toCell: cell)
    }
}
