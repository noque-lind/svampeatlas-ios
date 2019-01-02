//
//  ObservationImagesView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ObservationImagesView: UIView {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
       let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.dataSource = self
        view.clipsToBounds = false
        view.showsHorizontalScrollIndicator = false
        view.register(ObservationImageCell.self, forCellWithReuseIdentifier: "observationImageCell")
        view.register(ObservationImageCellAdd.self, forCellWithReuseIdentifier: "observationImageCellAdd")
        return view
    }()
    
    private var images = [UIImage]()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        clipsToBounds = false
        backgroundColor = UIColor.appPrimaryColour()
        
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive  = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    func configure(images: [UIImage]) {
        self.images = images
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: images.count, section: 0), at: UICollectionView.ScrollPosition.right, animated: false)
    }
}

extension ObservationImagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == images.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationImageCellAdd", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationImageCell", for: indexPath) as! ObservationImageCell
        cell.configureCell(image: images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: collectionView.frame.height)
    }
}


class ObservationImageCellAdd: UICollectionViewCell {
    
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 39).isActive = true
        imageView.image = #imageLiteral(resourceName: "AddImage")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}

class ObservationImageCell: UICollectionViewCell {
   
    private var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        clipsToBounds = false
        
        
        let imageViewContainerView: UIView = {
           let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = imageView.layer.cornerRadius
            view.layer.shadowOpacity = 0.4
            view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            view.addSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return view
        }()
        
        contentView.addSubview(imageViewContainerView)
        imageViewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageViewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageViewContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageViewContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configureCell(image: UIImage) {
        imageView.image = image
    }
}


