//
//  CategoryView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol CategoryViewDelegate: NSObjectProtocol {
    func categorySelected(category: Category)
}

struct Category {
    public private(set) var title: String
}

struct GenericRow<T> {
    let type: T
    let title: String
}

class NewCategoryView<T>: UIView {
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class CategoryView<T>: UIView {

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
        view.backgroundColor = UIColor.appThirdColour()
        view.alpha = 0
        view.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        view.layer.cornerRadius = 3
        return view
    }()
    
    var items: [GenericRow<T>]
    
    weak var delegate: CategoryViewDelegate?
    private var categories: [Category]
    private var firstIndex: Int
    private var selectedCategory: Category!
    private var hasSelectedFirstIndex = false
    private var dynamicCellWidth: Bool
    
    lazy var selectorViewWidthConstraint = NSLayoutConstraint()
    lazy var selectorViewCenterXConstraint = NSLayoutConstraint()
    
    init(withItems items: [GenericRow<T>]) {
        self.items = items
        for item in items {
            print(item.title)
        }
        super.init(frame: CGRect.zero)
    }
    
    init(dynamicCellWidth: Bool = true, categories: [GenericRow<T>], firstIndex: Int) {
        self.items = categories
        self.firstIndex = firstIndex
//        self.categories = categories
        self.dynamicCellWidth = dynamicCellWidth
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(selectorView)
        selectorViewWidthConstraint = selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (1.0/CGFloat(categories.count))/2)
        selectorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        selectorViewWidthConstraint.isActive = true
        backgroundColor = UIColor.appPrimaryColour()
    }
    
    func moveSelector(toCell cell: UICollectionViewCell) {
        selectorViewCenterXConstraint.isActive = false
        selectorViewCenterXConstraint = selectorView.centerXAnchor.constraint(equalTo: cell.centerXAnchor)
        selectorViewCenterXConstraint.isActive = true
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            self.selectorView.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

extension CategoryView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {fatalError("Could not deque categoryCell")}
        cell.configureCell(title: categories[indexPath.row].title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !hasSelectedFirstIndex && indexPath.row == firstIndex {
            selectedCategory = categories[indexPath.row]
            collectionView.selectItem(at: IndexPath.init(row: indexPath.row, section: 0), animated: true, scrollPosition: .top)
            cell.isSelected = true
            moveSelector(toCell: cell)
            delegate?.categorySelected(category: categories[indexPath.row])
            hasSelectedFirstIndex = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if dynamicCellWidth {
            let labelWidth = (categories[indexPath.row].title as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.appHeaderDetails()])
            return CGSize(width: labelWidth.width + 16, height: collectionView.frame.size.height)
        } else {
            return CGSize(width: collectionView.frame.width / CGFloat(categories.count), height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedCategory.title != categories[indexPath.row].title {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        delegate?.categorySelected(category: categories[indexPath.row])
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        
        moveSelector(toCell: cell)
        
        if indexPath.row == categories.count - 2 {
            collectionView.scrollToItem(at: IndexPath.init(row: indexPath.row + 1, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
        } else if indexPath.row == 1 {
            collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
        }
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectorView.transform = CGAffineTransform(translationX: -scrollView.contentOffset.x, y: 0.0)
//        scrollView.setContentOffset(CGPoint.zero, animated: false)
    }

}
