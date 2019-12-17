//
//  ObservationImagesView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import Photos

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
        view.contentInset = UIEdgeInsets(top: 0.0, left: 8, bottom: 0.0, right: 8.0)
        view.clipsToBounds = false
        view.showsHorizontalScrollIndicator = false
        view.register(ObservationImageCell.self, forCellWithReuseIdentifier: "observationImageCell")
        view.register(ObservationImageCellAdd.self, forCellWithReuseIdentifier: "observationImageCellAdd")
        return view
    }()
    
    private let expandedLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: ObservationImagesView.expandedHeight)
        layout.minimumLineSpacing = 16
        return layout
    }()
    
    static let collapsedHeight: CGFloat = 92
    static let expandedHeight: CGFloat = 200
    
    var onAddImageButtonPressed: (() -> ())?
    var imageDeleted: ((URL) -> ())?
    var shouldAnimateHeight: ((CGFloat) -> ())?
    
    var isExpanded: Bool = false
    
    private var images = [URL]() {
        didSet {
            if images.count > 0 && isExpanded == false {
                shouldAnimateHeight?(ObservationImagesView.expandedHeight)
                isExpanded = true
            } else if images.count == 0 && isExpanded == true {
                shouldAnimateHeight?(ObservationImagesView.collapsedHeight)
                isExpanded = false
            }
        }
    }
    
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
    
    func configure(imageURLS: [URL]) {
        self.images = imageURLS
        collectionView.reloadData()
    }
    
    func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
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
        cell.configureCell(imageURL: images[indexPath.row])
        cell.onSwipeUp = { [unowned self] imageURL in
            guard let index = self.images.firstIndex(of: imageURL) else {return}
            self.images.remove(at: index)
            self.imageDeleted?(imageURL)
            
            if self.images.count == 0 {
                self.collectionView.reloadData()
            } else {
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [.init(row: index, section: 0)])
                }, completion: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if images.count == 0 {
            return CGSize(width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right, height: collectionView.frame.height)
        } else if indexPath.row == images.endIndex {
            return CGSize(width: 100, height: collectionView.frame.height)
        } else {
            return CGSize(width: 180, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == images.count {
            onAddImageButtonPressed?()
        }
    }
    
    func addImage(imageURL: URL) {
        images.append(imageURL)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [.init(row: images.endIndex - 1, section: 0)])
        }) { (_) in
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: .init(row: self.images.endIndex, section: 0), at: .right, animated: true)
            }
        }
    }
}

class ObservationImageCellAdd: UICollectionViewCell {
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 39).isActive = true
        imageView.image = #imageLiteral(resourceName: "Icons_Utils_AddImage")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupView() {
        let imageViewContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 30
            view.backgroundColor = UIColor.appSecondaryColour()
            view.layer.shadowOpacity = 0.4
            view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            view.addSubview(imageView)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            return view
        }()
        
        contentView.addSubview(imageViewContainerView)
        imageViewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageViewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageViewContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageViewContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

protocol ObservationImageCellDelegate: class {
    func imageDeleted(image: UIImage?)
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
    
    private var imageURL: URL?
    var onSwipeUp: ((URL) -> ())?
    
    private var animator = UIViewPropertyAnimator()
    private var panGestureRecognizer = UIPanGestureRecognizer()
    
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
            
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
            panGestureRecognizer.delegate = self
            view.addGestureRecognizer(panGestureRecognizer)
            
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
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
                self.transform = CGAffineTransform(translationX: 0.0, y: -self.frame.height)
                self.alpha = 0
            })
            animator.addCompletion { [weak self] (position) in
                switch position {
                case .end:
                    if let imageURL = self?.imageURL {
                        self?.onSwipeUp?(imageURL)
                    }
    
                default: break
                }
            }
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            animator.fractionComplete = gesture.translation(in: self).y / -self.frame.height
        case .ended:
            if animator.fractionComplete >= 0.5 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                animator.stopAnimation(false)
                animator.finishAnimation(at: UIViewAnimatingPosition.start)
            }
        default:
            ()
        }
    }
    
    
    func configureCell(imageURL: URL) {
        self.imageURL = imageURL
        imageView.loadImage(url: imageURL)
    }
}

extension ObservationImageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


