//
//  ELPageControl.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ELPageControlDataSource: NSObjectProtocol {
    func numberOfPages() -> Int
}

protocol ELPageControlDelegate: NSObjectProtocol {
    func didChangePage(toPage page: Int)
}

class ELPageControl: UIPageControl {
    
    public weak var dataSource: ELPageControlDataSource! = nil {
        didSet {
            setupPageControl()
        }
    }
    
    public weak var delegate: ELPageControlDelegate? = nil
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    public func nextPage() {
        if currentPage == numberOfPages - 1 {
            currentPage = 0
        } else {
            currentPage = currentPage + 1
        }
        delegate?.didChangePage(toPage: self.currentPage)
    }
    
    public func reloadData() {
        setupPageControl()
    }
    
    private func setupView() {
        tintColor = UIColor.appWhite()
        self.addTarget(self, action: #selector(changedValue(sender:)), for: .valueChanged)
    }

    private func setupPageControl() {
        self.numberOfPages = dataSource!.numberOfPages()
    }
    
    @objc private func changedValue(sender: ELPageControl) {
        delegate?.didChangePage(toPage: sender.currentPage)
    }
}
