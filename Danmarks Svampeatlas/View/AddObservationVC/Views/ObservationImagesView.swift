//
//  ObservationImagesView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

protocol ObservationImagesViewDelegate: NavigationDelegate {
        func shouldAnimateHeightChanged()
}

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
    
    private lazy var expandedLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: expandedHeight)
        layout.minimumLineSpacing = 16
        return layout
    }()
    
    var heightConstraint: NSLayoutConstraint?
    
    private var collapsedHeight: CGFloat
    private var expandedHeight: CGFloat
    private var isExpanded: Bool = false
    weak var delegate: ObservationImagesViewDelegate?
    
    private var images = [UIImage]() {
        didSet {
            if images.count > 0 && isExpanded == false {
                heightConstraint?.isActive = false
                heightConstraint?.constant = expandedHeight
                isExpanded = true
                heightConstraint?.isActive = true
                delegate?.shouldAnimateHeightChanged()
            } else if images.count == 0 && isExpanded == true {
                heightConstraint?.isActive = false
                heightConstraint?.constant = collapsedHeight
                isExpanded = false
                heightConstraint?.isActive = true
                delegate?.shouldAnimateHeightChanged()
            }
        }
    }
    
    private weak var newObservation: NewObservation?
    
    init(newObservation: NewObservation, collapsedHeight: CGFloat = 92, expandedHeight: CGFloat = 200) {
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        super.init(frame: CGRect.zero)
        configure(newObservation: newObservation)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: images.count, section: 0), at: UICollectionView.ScrollPosition.right, animated: false)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        if images.count != 0 {
            heightConstraint = self.heightAnchor.constraint(equalToConstant: expandedHeight)
            isExpanded = true
        } else {
            heightConstraint = self.heightAnchor.constraint(equalToConstant: collapsedHeight)
            isExpanded = false
        }
        
        heightConstraint?.isActive = true
        
        clipsToBounds = false
        backgroundColor = UIColor.appPrimaryColour()
        
        addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive  = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    func configure(newObservation: NewObservation) {
        self.newObservation = newObservation
        self.images = newObservation.images
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
        cell.delegate = self
        if images.endIndex > indexPath.row {
            cell.configureCell(image: images[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if images.count == 0 {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        return CGSize(width: 180, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == images.count {
            let vc = CameraVC(cameraVCUsage: CameraVC.CameraVCUsage.imageCapture)
            vc.delegate = self
            delegate?.presentVC(vc)
        }
    }
}

extension ObservationImagesView: CameraVCDelegate {
    func imageReady(image: UIImage) {
        images.append(image)
        newObservation?.images.append(image)
        
        let newIndexPath = IndexPath(row: images.count, section: 0)

        
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [IndexPath(row: newIndexPath.row - 1, section: 0)])
            
        }) { (_) in
            
        }
        
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: newIndexPath, at: UICollectionView.ScrollPosition.right, animated: true)
        }
    }
    }

extension ObservationImagesView: ObservationImageCellDelegate {
    func imageDeleted(image: UIImage?) {
        guard let image = image, let index = images.firstIndex(of: image) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        images.remove(at: index)
        newObservation?.images.remove(at: index)
        
        if images.count == 0 {
            self.collectionView.reloadData()
        } else {
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
            }) { (_) in
                
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
        imageViewContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        imageViewContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
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
    
    weak var delegate: ObservationImageCellDelegate?
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
            animator.addCompletion { (position) in
                switch position {
                case .end:
                    self.delegate?.imageDeleted(image: self.imageView.image)
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
    
    
    func configureCell(image: UIImage) {
        imageView.image = image
    }
}

extension ObservationImageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


