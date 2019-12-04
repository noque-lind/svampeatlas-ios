//
//  CategoryView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol CategoryViewDelegate: NSObjectProtocol {
    func categorySelected(category: Any)
}

struct Category<T>: Equatable {
    static func == (lhs: Category<T>, rhs: Category<T>) -> Bool {
        if lhs.title == rhs.title {
            return true
        } else {
            return false
        }
    }
    
   let type: T
   let title: String
}

class CategoryView<T>: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "categoryCell")
        return collectionView
    }()
    
    private var selectorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 3).isActive = true
        view.backgroundColor = UIColor.appThird()
        view.alpha = 0
        view.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        view.layer.cornerRadius = 3
        return view
    }()
    
    var categorySelected: ((T) -> ())? = nil
    private var items: [Category<T>]
    var selectedItem: Category<T>
    private var firstIndex: Int?
    private var cellsWidth: CGFloat
    
    private var selectorViewWidthConstraint = NSLayoutConstraint()
    private var selectorViewCenterXConstraint = NSLayoutConstraint()
    
    init(categories: [Category<T>], firstIndex: Int = 0) {
        self.items = categories
        self.firstIndex = firstIndex
        self.selectedItem = categories[firstIndex]
        self.cellsWidth = categories.reduce(0, {(($1.title as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.appTitle()]).width) + 16 + $0})
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    deinit {
        debugPrint("CategoryView Deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupView() {
        backgroundColor = UIColor.appPrimaryColour()
        
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(selectorView)
        selectorViewWidthConstraint = selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (1.0/CGFloat(items.count))/2)
        selectorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectorViewWidthConstraint.isActive = true
    }
    
    private func moveSelector(toCell cell: UICollectionViewCell) {
        selectorViewCenterXConstraint.isActive = false
        selectorViewCenterXConstraint = selectorView.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
        selectorViewCenterXConstraint.isActive = true
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            self.selectorView.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func selectCategory(category: T, force: Bool) {
        categorySelected?(category)
    }
    
    func moveSelector(toCellAtIndexPath indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            moveSelector(toCell: cell)
            selectedItem = items[indexPath.row]
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.bottom)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {fatalError()}
        cell.configureCell(title: items[indexPath.row].title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == firstIndex {
            selectedItem = items[indexPath.row]
            collectionView.selectItem(at: IndexPath.init(row: indexPath.row, section: 0), animated: true, scrollPosition: .top)
            cell.isSelected = true
            moveSelector(toCell: cell)
            categorySelected?(items[indexPath.row].type)
            firstIndex = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellsWidth > collectionView.frame.width {
            let labelWidth = (items[indexPath.row].title as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.appPrimary()])
            return CGSize(width: labelWidth.width + 16, height: collectionView.frame.size.height)
        } else {
            return CGSize(width: collectionView.frame.width / CGFloat(items.count), height: collectionView.frame.size.height)
        }
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
        categorySelected?(items[indexPath.row].type)
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        moveSelector(toCell: cell)
        
        if indexPath.row == items.count - 2 {
            collectionView.scrollToItem(at: IndexPath.init(row: indexPath.row + 1, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
        } else if indexPath.row == 1 {
            collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
        }
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectorView.transform = CGAffineTransform(translationX: -scrollView.contentOffset.x, y: 0.0)
    }

}
