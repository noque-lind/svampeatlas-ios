//
//  ImageVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {
    
    lazy var imagesCollectionView: ImagesCollectionView = {
        let collectionView = ImagesCollectionView(imageContentMode: UIView.ContentMode.scaleAspectFit)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configure(images: images)
        return collectionView
    }()
    
    var images: [Image]
    var selectedIndexPath: IndexPath
    
    var interactor: showImageAnimationInteractor?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var currentlyShownCell: UICollectionViewCell!
    var currentlyShownCellOriginFrame: CGRect!
    
    init(images: [Image], selectedIndexPath: IndexPath) {
        self.images = images
        self.selectedIndexPath = selectedIndexPath
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder not implemented inside ImageVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imagesCollectionView.setSelectedImage(atIndexPath: selectedIndexPath)
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        
        view.addSubview(imagesCollectionView)
        imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
        panGestureRecognizer.delegate = self
        imagesCollectionView.addGestureRecognizer(panGestureRecognizer)
        view.backgroundColor = UIColor.black
    }
}

extension ImageVC: UIGestureRecognizerDelegate {
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
                    guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
                    let translation = gesture.translation(in: gesture.view!)
                    if translation.x != 0 || translation.y != 0 {
                        let angle = atan2(abs(translation.x), translation.y)
                        return angle < .pi / 8
                    }
                    return false
                }

    @objc func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)


        let progress = CGFloat(downwardMovementPercent)

        guard let interactor = interactor else {return}
        switch sender.state {
        case .began:
            guard let currentCell = imagesCollectionView.currentlyShownCell else {return}
            currentlyShownCell = currentCell
            currentlyShownCellOriginFrame = currentCell.frame
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = true
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.finish()
        default:
            break
        }
}
}


