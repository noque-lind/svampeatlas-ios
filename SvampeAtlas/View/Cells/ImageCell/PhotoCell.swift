//
//  PhotoCell.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        scrollView.delegate = self
    }
    
    func configureCell(url: String) {
        DataService.instance.getImage(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
}

extension PhotoCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
