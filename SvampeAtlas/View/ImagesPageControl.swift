//
//  ImagesPageControl.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ImagesPageControlDataSource {
    func numberOfPages() -> Int
}

protocol ImagesPageControlDelegate {
    func didChangePage(toPage page: Int)
}

class ImagesPageControl: UIPageControl {
    
    public var dataSource: ImagesPageControlDataSource? = nil {
        didSet {
            setupPageControl()
        }
    }
    
    public var delegate: ImagesPageControlDelegate? = nil
    
    public func nextPage() {
        if currentPage == numberOfPages - 1 {
            currentPage = 0
        } else {
            currentPage = currentPage + 1
        }
        delegate?.didChangePage(toPage: self.currentPage)
    }
    
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(changedValue(sender:)), for: .valueChanged)
    }
    
    
    private func setupPageControl() {
        self.numberOfPages = dataSource!.numberOfPages()
    }
    
    @objc private func changedValue(sender: ImagesPageControl) {
        delegate?.didChangePage(toPage: sender.currentPage)
    }
}
