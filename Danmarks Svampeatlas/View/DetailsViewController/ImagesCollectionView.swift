//
//  ImagesCollectionView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ImagesCollectionView: UIView {
    
    private var imageContentMode: UIView.ContentMode
    private var images = [Image]()
    
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
        collectionView.backgroundColor = UIColor.black
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        return collectionView
    }()
    
    var didSelectImage: ((IndexPath) -> Void)?
    
    var currentlyShownCell: UICollectionViewCell? {
        get {
            return collectionView.visibleCells.first
        }
    }
    
    deinit {
        print("was deinited")
    }
    
    private var imageScrollTimer: Timer?
    
    init(imageContentMode: UIView.ContentMode) {
        self.imageContentMode = imageContentMode
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
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
        pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -2).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func handleTimer() {
        pageControl.nextPage()
    }
    
    func configure(images: [Image]) {
        self.images = images
        collectionView.reloadData()
        pageControl.reloadData()
    }
    
    func configureTimer() {
        imageScrollTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    func setSelectedImage(atIndexPath indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.pageControl.currentPage = indexPath.row
        }
        
    }
    
    func invalidate() {
        imageScrollTimer?.invalidate()
        imageScrollTimer = nil
    }
}

extension ImagesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {fatalError("Failed to deque imageCell")}
        cell.configureCell(contentMode: imageContentMode, url: images[indexPath.row].url, photoAuthor: images[indexPath.row].photographer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectImage?(indexPath)
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
