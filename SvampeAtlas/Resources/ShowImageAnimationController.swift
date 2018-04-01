//
//  ShowImageAnimationController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 31/03/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ShowImageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let imageFrame: CGRect
    
    init(imageFrame: CGRect) {
        self.imageFrame = imageFrame
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? DetailsViewController, let toVC = transitionContext.viewController(forKey: .to), let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else {return}

    
    let containerView = transitionContext.containerView
    let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = imageFrame

        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
    

}
}
