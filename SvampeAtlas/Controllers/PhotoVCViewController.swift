//
//  PhotoVCViewController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/04/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class PhotoVCViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [Images]()
    var interactor: showImageAnimationInteractor?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var currentlyShownCell: UICollectionViewCell!
    var currentlyShownCellOriginFrame: CGRect!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        setupView()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setupView() {
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.black
    }
}


extension PhotoVCViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.configureCell(url: images[indexPath.row].uri)
        currentlyShownCell = cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
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

}

extension PhotoVCViewController {
    @objc func close() {
        dismiss(animated: true, completion: nil)
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
            currentlyShownCellOriginFrame = currentlyShownCell.frame
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
