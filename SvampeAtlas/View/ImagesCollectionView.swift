//
//  ImagesCollectionView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ImagesCollectionViewDelegate: class {
    func changeNavigationbarBackgroundViewAlpha(_ alpha: CGFloat)
    func didSelectImage(atIndexPath indexPath: IndexPath)
}


class ImagesCollectionView: UIView {

    private var heightConstraint = NSLayoutConstraint()
    private var defaultHeight: CGFloat?
    private var navigationBarHeight: CGFloat?
    private var imageContentMode: UIViewContentMode
    
    
    private var images = [Images]()
    
    private lazy var pageControl: ELPageControl = {
       let pageControl = ELPageControl()
        pageControl.delegate = self
        pageControl.dataSource = self
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
       let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    deinit {
        print("was deinited")
    }
    
    private var imageScrollTimer: Timer?
    
    weak var delegate: ImagesCollectionViewDelegate? = nil
    
    init(imageContentMode: UIViewContentMode, defaultHeight: CGFloat? = nil, navigationBarHeight: CGFloat?) {
        if let defaultHeight = defaultHeight {
            self.defaultHeight = defaultHeight
        }
        
        self.navigationBarHeight = navigationBarHeight
        self.imageContentMode = imageContentMode
        super.init(frame: CGRect.zero)
        setupView()
        
        guard defaultHeight != nil else {return}
        heightConstraint = self.heightAnchor.constraint(equalToConstant: defaultHeight!)
        heightConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("coder aDecoder not implemented inside ImagesCollectionView")
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        addSubview(pageControl)
        pageControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func handleTimer() {
        print("Timer fired")
        pageControl.nextPage()
    }
    
    func configure(images: [Images]) {
        self.images = images
        collectionView.reloadData()
        pageControl.reloadData()
    }
    
    func setupHeightConstraint(defaultHeight: CGFloat, navigationBarHeight: CGFloat) {
        heightConstraint = heightAnchor.constraint(equalToConstant: defaultHeight)
        heightConstraint.isActive = true
        self.defaultHeight = defaultHeight
        self.navigationBarHeight = navigationBarHeight
    }
    
    func configureTransform(deltaValue value: CGFloat) {
        transform = CGAffineTransform(translationX: 0.0, y: -value)
        let percentValue = 1 - ((frame.maxY - navigationBarHeight!) / (defaultHeight! - navigationBarHeight!))
        delegate?.changeNavigationbarBackgroundViewAlpha(percentValue)
    }
    
    func configureHeightConstraint(deltaValue value: CGFloat) {
        heightConstraint.constant = defaultHeight! - value
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func configureTimer() {
        imageScrollTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    func invalidate() {
        imageScrollTimer?.invalidate()
        imageScrollTimer = nil
    }
}

extension ImagesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {fatalError("Failed to deque imageCell")}
        cell.configureCell(contentMode: imageContentMode, url: images[indexPath.row].uri, photoAuthor: images[indexPath.row].photographer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       delegate?.didSelectImage(atIndexPath: indexPath)
    }
}

extension ImagesCollectionView: ELPageControlDelegate, ELPageControlDataSource {
    func didChangePage(toPage page: Int) {
        let indexPath = IndexPath(row: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func numberOfPages() -> Int {
        return images.count
    }
}

extension ImagesCollectionView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if imageScrollTimer != nil {
            configureTimer()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if imageScrollTimer != nil {
            imageScrollTimer?.invalidate()
        }
    }
}
