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
        let collectionView = ImagesCollectionView(imageContentMode: UIViewContentMode.scaleAspectFit, defaultHeight: nil, navigationBarHeight: self.navigationController?.navigationBar.frame.maxY)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.configure(images: images)
        return collectionView
    }()
    
    var images: [Images]
    
    var interactor: showImageAnimationInteractor?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var currentlyShownCell: UICollectionViewCell!
    var currentlyShownCellOriginFrame: CGRect!
    
    init(images: [Images]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder not implemented inside ImageVC")
    }
    
    private func setupView() {
        
        view.addSubview(imagesCollectionView)
        imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
//        panGestureRecognizer.delegate = self
//        collectionView.addGestureRecognizer(panGestureRecognizer)
//        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.black
    }
}


//extension PhotoVCViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
//        cell.configureCell(url: images[indexPath.row].uri)
//        currentlyShownCell = cell
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//    }
//
//        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//            guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
//
//            let translation = gesture.translation(in: gesture.view!)
//            if translation.x != 0 || translation.y != 0 {
//                let angle = atan2(abs(translation.x), translation.y)
//                return angle < .pi / 8
//            }
//            return false
//        }
//
//}

//extension PhotoVCViewController {
//    @objc func close() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @objc func handleGesture(sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: view)
//        let verticalMovement = translation.y / view.bounds.height
//        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
//        let downwardMovementPercent = fminf(downwardMovement, 1.0)
//
//
//        let progress = CGFloat(downwardMovementPercent)
//
//        guard let interactor = interactor else {return}
//        switch sender.state {
//        case .began:
//            currentlyShownCellOriginFrame = currentlyShownCell.frame
//            interactor.hasStarted = true
//            dismiss(animated: true, completion: nil)
//        case .changed:
//            interactor.shouldFinish = true
//            interactor.update(progress)
//        case .cancelled:
//            interactor.hasStarted = false
//            interactor.cancel()
//        case .ended:
//            interactor.hasStarted = false
//            interactor.finish()
//        default:
//            break
//        }
//}
//}


