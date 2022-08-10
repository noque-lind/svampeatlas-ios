//
//  PhotoLibraryButton.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 30/11/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class PhotoLibraryButton: UIButton {
    
    var pressed: (() -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = CGFloat.cornerRadius()
        clipsToBounds = true
        contentMode = .scaleAspectFill
        layer.shadowOpacity = Float.shadowOpacity()
        addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func pressed(sender: UIButton) {
        pressed?()
    }
    
    func setPhotosLibraryThumbnail() {
        ELPhotos.fetchPhotoLibraryThumbnail(size: self.frame.size) { [weak self] (image) in
            if let image = image {
                self?.setImage(image, for: [])
            } else {
                self?.setImage(#imageLiteral(resourceName: "Icons_Utils_PhotoLibrary"), for: [])
            }
        }
    }
}
