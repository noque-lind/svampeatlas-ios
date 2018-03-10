//
//  DetailsViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imagesCollectionView: ImagesCollectionView!
    @IBOutlet weak var pageControl: ImagesPageControl!
    @IBOutlet weak var scrollView: MushroomDetailsScrollView!
    
    var mushroom: Mushroom!
    var imageScrollTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        pageControl.delegate = self
        pageControl.dataSource = self
        scrollView.delegate = self
        setupImageTimer()
        setupScrollView()
    }

    private func setupImageTimer() {
        imageScrollTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(handleImageTimer), userInfo: nil, repeats: true)
    }
    
    func setupScrollView() {
//        scrollView.setupInsets(collectionViewHeight: imagesCollectionView.defaultHeightConstant)
        scrollView.configureScrollView(withMushroom: mushroom)
    }
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mushroom.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            cell.configureCell(url: (mushroom.images[indexPath.row]?.uri)!, photoAuthor: mushroom.images[indexPath.row]!.photographer)
        return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    
    @objc func handleImageTimer() {
        pageControl.nextPage()
    }
    
}

extension DetailsViewController: ImagesPageControlDataSource, ImagesPageControlDelegate{
    func numberOfPages() -> Int {
        return mushroom.images.count
    }
    
    func didChangePage(toPage page: Int) {
        let indexPath = IndexPath(row: page, section: 0)
        imagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if imagesCollectionView.heightConstraint.constant != imagesCollectionView.minimumHeight {
                    imagesCollectionView.heightConstraint.constant =  imagesCollectionView.heightConstraint.constant - ((scrollView.contentOffset.y) / 3)
                    imagesCollectionView.collectionViewLayout.invalidateLayout()
                    scrollView.setContentOffset(CGPoint.zero, animated: false)
            } else {
                if scrollView.contentOffset.y < 0 {
                    imagesCollectionView.heightConstraint.constant =  imagesCollectionView.heightConstraint.constant - ((scrollView.contentOffset.y) / 3)
                    imagesCollectionView.collectionViewLayout.invalidateLayout()
                    scrollView.setContentOffset(CGPoint.zero, animated: false)
                }
            }
            
            
            
            
            
    }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.scrollView {
            imagesCollectionView.animateToPosition()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            imagesCollectionView.animateToPosition()
        } else {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        imageScrollTimer.invalidate()
        setupImageTimer()
        }
    }
}

