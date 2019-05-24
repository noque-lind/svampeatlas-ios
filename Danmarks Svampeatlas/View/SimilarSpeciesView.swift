//
//  SimilarSpeciesView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class SimilarSpeciesView: UIView {

    lazy var label: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Forvekslingsmuligheder"
        return label
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
       let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SimilarSpeciesCell.self, forCellWithReuseIdentifier: "similarSpeciesCell")
        return collectionView
    }()

    var mushrooms = [Mushroom]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.intrinsicContentSize.height).isActive = true
        
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension SimilarSpeciesView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mushrooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "similarSpeciesCell", for: indexPath) as? SimilarSpeciesCell else {fatalError()}
        cell.configureCell(mushroom: mushrooms[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: collectionView.frame.size.height)
    }
}

class SimilarSpeciesCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.shadowOpacity = 0.4
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimary()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func configureCell(mushroom: Mushroom) {
//        DataService.instance.getThumbImageForMushroom(url: mushroom.images![0].thumbUrl!) { (image) in
//            self.imageView.image = image
//        }
        
        
        titleLabel.text = mushroom.danishName ?? mushroom.fullName
    }
}
