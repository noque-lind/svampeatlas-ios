//
//  CategoryCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 09/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import UIKit

class CategoryCell: UICollectionViewCell {
    
    private let label = UILabel().then({
        $0.textColor = UIColor.appWhite().withAlphaComponent(0.7)
        $0.font = UIFont.appPrimary()
        $0.textAlignment = .center
    })
    
    private let spinner = UIActivityIndicatorView().then({
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.style = .white
        $0.hidesWhenStopped = true
    })
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = UIColor.appWhite()
            } else {
                label.textColor = UIColor.appWhite().withAlphaComponent(0.7)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        contentView.addSubview(label)
        ELSnap.snapView(label, toSuperview: contentView)
        contentView.addSubview(spinner)
        ELSnap.snapView(spinner, toSuperview: contentView)
    }
    
    func configureCell(title: String, loading: Bool) {
        label.text = title
        if loading {
            spinner.startAnimating()
            label.isHidden = true
        } else {
            spinner.stopAnimating()
            label.isHidden = false
        }
    }
}
