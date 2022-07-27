//
//  ShowImageAnimationController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class showImageAnimationInteractor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

class ShowImageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let imageFrame: CGRect
    private let isBeingPresented: Bool
    
    init(isBeingPresented: Bool, imageFrame: CGRect) {
        self.isBeingPresented = isBeingPresented
        self.imageFrame = imageFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? ImageVC,
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else {return}
    
    let containerView = transitionContext.containerView
    let finalFrame = transitionContext.finalFrame(for: toVC)
        
//        snapshot.frame = imageFrame
        
        if isBeingPresented {
            
        } else {
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
       
            let translationTransform = CGAffineTransform(translationX: 0.0, y: fromVC.view.frame.height)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromVC.currentlyShownCell.transform = CGAffineTransform.identity
                fromVC.imagesCollectionView.transform = translationTransform
                fromVC.currentlyShownCell.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                fromVC.view.alpha = 0
            }) { (_) in
                
                if transitionContext.transitionWasCancelled {
                    transitionContext.completeTransition(false)
                    fromVC.currentlyShownCell.frame = fromVC.currentlyShownCellOriginFrame
                } else {
                    transitionContext.completeTransition(true)
                }
            }
            
        }

}
}
