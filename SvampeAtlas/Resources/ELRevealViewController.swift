//
//  ELMenuController.swift
//  InteractiveSlideoutMenu
//
//  Created by Emil Lind on 08/10/2017.
//  Copyright © 2017 Thorn Technologies, LLC. All rights reserved.
//

import UIKit

public enum ELSidemenuPosition {
    case left
    case right
}

public enum ELButtonState {
    case open
    case close
}

public enum ELAnimationType {
    case springReveal
    case flyerReveal
}

public struct ELConfiguration {
    public private(set) var animationType: ELAnimationType
    public private(set) var menuWidthPercentage: CGFloat
    public private(set) var menuThresholdPercentage: CGFloat
    
}

fileprivate let ELSegueLeftVCIdentifier = "EL_left"
fileprivate let ELSegueMainVCIdentifier = "EL_main"
fileprivate let ELSegueRightVCIdentifier = "EL_right"

final class ELRevealViewControllerSegueSetController: UIStoryboardSegue {
    override func perform() {
        let identifier = self.identifier!
        let fromVC = source as? ELRevealViewController
        let toVC = destination
        
        if (identifier == ELSegueMainVCIdentifier) {
            fromVC?.addViewControllerAsChildViewController(childViewController: toVC)
        } else if (identifier == ELSegueLeftVCIdentifier) {
            fromVC?.currentLeftViewController = toVC
            fromVC?.toggleSideMenu()
        } else if (identifier == ELSegueRightVCIdentifier) {
            fromVC?.currentRightViewController = toVC
            fromVC?.toggleSideMenu()
        }
    }
}

final class ELRevealViewControllerSeguePushController: UIStoryboardSegue {
    open override func perform() {
        let fromVC = source.eLRevealViewController()
        let dvc = destination
        fromVC?.pushNewViewController(viewController: dvc)
    }
}

protocol ELRevealViewControllerDelegate: class {
    func hamburgerButton(state: ELButtonState)
    func willShowLeftMenu()
    func willCloseLeftMenu()
    func didOpenLeftMenu()
    func didCloseLeftMenu()
    func isAllowedToPushMenu() -> Bool?
}

extension ELRevealViewControllerDelegate {
    func willShowLeftMenu() {}
    func willCloseLeftMenu() {}
    func didOpenLeftMenu() {}
    func didCloseLeftMenu() {}
    func hamburgerButton(state: ELButtonState) {}
}

@IBDesignable final class ELRevealViewController: UIViewController {
    // IBConfigurables
    @IBInspectable private var revealVCLeft: Bool = true {
        didSet {
            if revealVCLeft {
                sideMenuPosition = .left
            }
        }
    }
    
    @IBInspectable private var revealVCRight: Bool = false {
        didSet {
            if revealVCRight {
                sideMenuPosition = .right
            }
        }
    }
    
    
    @IBInspectable private var springAnimation: Bool = true {
        didSet {
            if springAnimation {
                animationType = .springReveal
            }
        }
    }
    
    @IBInspectable private var flyerAnimation: Bool = false {
        didSet {
            if flyerAnimation {
                animationType = .flyerReveal
            }
        }
    }
    
    @IBInspectable var menuWidthPercentage: CGFloat = MenuHelper.menuWidth {
        didSet {
            MenuHelper.menuWidth = menuWidthPercentage
        }
    }
    
    @IBInspectable var menuThresholdPercent: CGFloat = MenuHelper.percentThreshold {
        didSet {
            MenuHelper.percentThreshold = menuThresholdPercent
        }
    }
    
    // End of IBConfigurables
    
    fileprivate let interactor = Interactor()
    fileprivate var shouldShowNewViewControllerAnimation = false
    fileprivate var newViewController: UIViewController?
    
    /**
     Read this value, if you want to know whether ELRevealViewController side menu is currently showing or not.
     */
    public fileprivate(set) var sideMenuShowing: Bool = false
    
    /**
     The currenct viewcontroller acting as the mainVC by ELRevealViewController
     */
    public fileprivate(set) var currentViewController: UIViewController!
    
    public fileprivate(set) var currentLeftViewController: UIViewController? {
        didSet {
            if currentRightViewController != nil && currentLeftViewController != nil {
                currentRightViewController = nil
            }
        }
    }
    
    public fileprivate(set) var currentRightViewController: UIViewController? {
        didSet {
            if currentLeftViewController != nil && currentRightViewController != nil {
                currentLeftViewController = nil
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let prefersStatusBarHidden = currentViewController.childViewControllerForStatusBarHidden?.prefersStatusBarHidden else {return false}
        return prefersStatusBarHidden
    }
    
    /**
     Assign your view controller to this delegate, if you want to be notified of certain ELRevealViewController events.
     */
    weak public var delegate: ELRevealViewControllerDelegate? = nil
    
    /**
     Read this value to determine whether the ELRevealViewController will be revealed to the left or right side. Write to this value to change which side it should be revealed. Default is .left.
     */
    public var sideMenuPosition: ELSidemenuPosition = ELSidemenuPosition.left {
        didSet {
            switch sideMenuPosition {
            case .left:
                edgePan.edges = .left
            case .right:
                edgePan.edges = .right
            }
        }
    }
    
    /**
     Set this variable to define which animation type you wish to use.
     */
    public var animationType: ELAnimationType = ELAnimationType.springReveal
    
    
    /**
     This is the edgePan that handles the interactive revealing of the ELRevealViewController. You should not alter any values except .isEnabled, if you don't want your side menu to be interactive, and only usable by button.
     */
    public var edgePan = UIScreenEdgePanGestureRecognizer()
    
    /**
     Use this function to push a new view controller to be the currentViewController of ELRevealViewController. The revealVC will still be available after the transition. If the side menu is opened, the pushing will happen animated depending on the set animationtype.
     */
    public func pushNewViewController(viewController: UIViewController) {
        if sideMenuShowing {
            if type(of: viewController) === type(of: currentViewController) {
                shouldShowNewViewControllerAnimation = false
            } else {
                shouldShowNewViewControllerAnimation = true
                newViewController = viewController
            }
            DispatchQueue.main.async {
                self.toggleSideMenu()
            }
        }
        //            removeChildViewControllerFromViewController(childViewController: currentViewController)
        //            addViewControllerAsChildViewController(childViewController: viewController)
    }
    
    /**
     Assign this function to be the target of your button, that you which should trigger the revealing. When pressed, the side menu will appear on either the left, or right side, depending on the value of ELsideMenuPosition. You can also call this function in code, when certain events happens.
     */
    @objc func toggleSideMenu() {
        if sideMenuShowing {
            currentRightViewController?.dismiss(animated: true, completion: nil)
            currentLeftViewController?.dismiss(animated: true, completion: nil)
        } else {
            if currentLeftViewController != nil && sideMenuPosition == .left {
                self.present(currentLeftViewController!, animated: true, completion: {})
            } else if currentRightViewController != nil && sideMenuPosition == .right {
                self.present(currentRightViewController!, animated: true, completion: {})
            } else {
                switch sideMenuPosition {
                case .left:
                    if !self.performSegue(id: ELSegueLeftVCIdentifier, sender: nil) {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        currentLeftViewController = storyboard.instantiateViewController(withIdentifier: "LeftVC")
                        prepareSideVC(viewController: currentLeftViewController!)
                        present(currentLeftViewController!, animated: true, completion:  nil)
                    }
                case .right:
                    if !self.performSegue(id: ELSegueRightVCIdentifier, sender: nil) {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        currentRightViewController = storyboard.instantiateViewController(withIdentifier: "RightVC")
                        prepareSideVC(viewController: currentRightViewController!)
                        present(currentRightViewController!, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /**
     Use this initializer in an environment where you are not using storyboards at all. Both the mainVC, and revealVC should be entirely build and done programmatically. If no configuration is passed, default values are used which are: ELAnimationType.springReveal, menuWidthPercentage: 0.5, menuThresholdPercentage: 0.3.
     */
    public init(mainVC: UIViewController, revealVC: UIViewController, revealVCPosition: ELSidemenuPosition, configuation: ELConfiguration?) {
        super.init(nibName: nil, bundle: nil)
        addViewControllerAsChildViewController(childViewController: mainVC)
        prepareSideVC(viewController: revealVC)
        
        switch revealVCPosition {
        case .left:
            currentLeftViewController = revealVC
        case .right:
            currentRightViewController = revealVC
        }
        sideMenuPosition = revealVCPosition
        switch sideMenuPosition {
        case .left:
            edgePan.edges = .left
        case .right:
            edgePan.edges = .right
        }
        
        guard let configuation = configuation else {return}
        animationType = configuation.animationType
        MenuHelper.menuWidth = configuation.menuWidthPercentage
        MenuHelper.percentThreshold = configuation.menuThresholdPercentage
    }
    
    /**
     Use this initializer in an environment where you are partially using storyboards, and you have designed your revealVC in a Main.storyboard file. NOTE: Your reveal VC must have either "LeftVC" or "RightVC" as a storyboard identifier, otherwise it will cause the application to crash. If no configuration is passed, default values are used which are: ELAnimationType.springReveal, menuWidthPercentage: 0.5, menuThresholdPercentage: 0.3.
     */
    public init(mainVC: UIViewController, revealVCPosition: ELSidemenuPosition, configuation: ELConfiguration?) {
        super.init(nibName: nil, bundle: nil)
        addViewControllerAsChildViewController(childViewController: mainVC)
        sideMenuPosition = revealVCPosition
        
        switch sideMenuPosition {
        case .left:
            edgePan.edges = .left
        case .right:
            edgePan.edges = .right
        }
        
        guard let configuation = configuation else {return}
        animationType = configuation.animationType
        MenuHelper.menuWidth = configuation.menuWidthPercentage
        MenuHelper.percentThreshold = configuation.menuThresholdPercentage
    }
    
    /**
     Use this initializer in an environment where you have designed all your viewcontrollers in storyboard, but would prefer to programmatically setup your application. NOTE: Will crash if it could not find viewcontrollers with the specified identifiers inside Main.storyboard. They should be EL_main for your mainVC and EL_left or EL_right depending on the specified revealVCPosition. If no configuration is passed, default values are used which are: ELAnimationType.springReveal, menuWidthPercentage: 0.5, menuThresholdPercentage: 0.3.
     */
    public init(mainVCIdentifier: String, revealVCIdentifier: String, revealVCPosition: ELSidemenuPosition, configuation: ELConfiguration?) {
        super.init(nibName: nil, bundle: nil)
        let mainVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: mainVCIdentifier)
        addViewControllerAsChildViewController(childViewController: mainVC)
        
        let revealVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: revealVCIdentifier)
        prepareSideVC(viewController: revealVC)
        switch revealVCPosition {
        case .left:
            currentLeftViewController = revealVC
        case .right:
            currentRightViewController = revealVC
        }
        sideMenuPosition = revealVCPosition
        
        switch sideMenuPosition {
        case .left:
            edgePan.edges = .left
        case .right:
            edgePan.edges = .right
        }
        
        guard let configuation = configuation else {return}
        animationType = configuation.animationType
        MenuHelper.menuWidth = configuation.menuWidthPercentage
        MenuHelper.percentThreshold = configuation.menuThresholdPercentage
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    internal override func awakeFromNib() {
        firstAppInit()
        super.awakeFromNib()
    }
    
    
    //    Functions not accesible to developers using this framework.
    
    /**
     This function finds the mainVC either via Segue or Storyboard identifier.
     */
    private func firstAppInit() {
        if !self.performSegue(id: ELSegueMainVCIdentifier, sender: nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
            addViewControllerAsChildViewController(childViewController: mainVC)
        }
    }
    
    fileprivate func reset() {
        currentLeftViewController?.dismiss(animated: false, completion: nil)
        currentRightViewController?.dismiss(animated: false, completion: nil)
        view = nil
        sideMenuShowing = false
        UIApplication.shared.keyWindow?.addSubview(view)
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        addViewControllerAsChildViewController(childViewController: currentViewController)
        setupEdgePan()
    }
    
    fileprivate func addViewControllerAsChildViewController(childViewController: UIViewController) {
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(childViewController)
        view.insertSubview(childViewController.view, at: 0)
        childViewController.didMove(toParentViewController: self)
        currentViewController = childViewController
    }
    
    fileprivate func removeChildViewControllerFromViewController(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
    
    
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ELSegueLeftVCIdentifier || segue.identifier == ELSegueRightVCIdentifier {
            prepareSideVC(viewController: segue.destination)
        }
    }
    
    @objc fileprivate func handleClosePanGesture(sender: UIPanGestureRecognizer) {
        let view = currentLeftViewController?.view ?? currentRightViewController?.view
        let translation = sender.translation(in: view!)
        var progress: CGFloat!
        switch sideMenuPosition {
        case .left:
            progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view!.bounds, direction: .Left)
        case .right:
            progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view!.bounds, direction: .Right)
        }
        MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor, openAnimation: false, delegate: delegate) {
            self.toggleSideMenu()
        }
        
    }
    
    @objc fileprivate func handleEdgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        if delegate?.isAllowedToPushMenu() == true || delegate?.isAllowedToPushMenu() == nil {
            let translation = sender.translation(in: view)
            var progress: CGFloat!
            switch sideMenuPosition {
            case .left:
                progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
            case .right:
                progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
            }
            MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor, openAnimation: true, delegate: delegate) {
                self.toggleSideMenu()
            }
        }
    }
    
    private func prepareSideVC(viewController: UIViewController) {
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        setupEdgePan()
        super.viewDidLoad()
    }
    
    private func setupEdgePan() {
        switch sideMenuPosition {
        case .left:
            edgePan.edges = .left
        case .right:
            edgePan.edges = .right
        }
        edgePan.addTarget(self, action: #selector(handleEdgePanGesture(sender:)))
        view.addGestureRecognizer(edgePan)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if sideMenuShowing {
            reset()
        }
    }
}

extension ELRevealViewController: UIViewControllerTransitioningDelegate {
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ELAnimator(isBeingPresented: true, animationType: animationType)
    }
    
    
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ELAnimator(isBeingPresented: false, animationType: animationType)
    }
    
    
    internal func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.hasStarted {
            return interactor
        } else {
            delegate?.hamburgerButton(state: .close)
            return nil
        }
    }
    
    
    internal func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactor.hasStarted {
            return interactor
        } else {
            delegate?.hamburgerButton(state: .open)
            return nil
        }
    }
}

fileprivate enum Direction {
    case Left
    case Right
}

fileprivate struct MenuHelper {
    static var menuWidth: CGFloat = 0.5
    static var percentThreshold: CGFloat = 0.3
    
    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat {
        
        let pointOnAxis: CGFloat
        let axisLenght: CGFloat
        
        switch direction {
        case .Left, .Right:
            pointOnAxis = translationInView.x
            axisLenght = viewBounds.width
        }
        
        let movementOnAxis = pointOnAxis / axisLenght
        let positiveMovementOnAxis: Float
        let positiveMovementOnAxisPercent: Float
        
        switch direction {
        case .Right:
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .Left:
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    
    fileprivate static func mapGestureStateToInteractor(gestureState: UIGestureRecognizerState, progress: CGFloat, interactor: Interactor?, openAnimation: Bool, delegate: ELRevealViewControllerDelegate?, triggerSegue: @escaping () -> Void) {
        guard let interactor = interactor else {return}
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish(): interactor.cancel()
            if interactor.shouldFinish {
                openAnimation ? delegate?.hamburgerButton(state: .open): delegate?.hamburgerButton(state: .close)
            }
        default: break
        }
    }
}




fileprivate class ELAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    private var _isBeingPresented = false
    private var _animationType: ELAnimationType
    private var _safeAreaLayoutGuideExtendedEdges: UIEdgeInsets?
    
    init(isBeingPresented: Bool, animationType: ELAnimationType) {
        _isBeingPresented = isBeingPresented
        _animationType = animationType
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    fileprivate func springRevealPresentAnim(_ toVC: UIViewController, _ fromVC: ELRevealViewController, _ containerView: UIView, _ transitionContext: UIViewControllerContextTransitioning, _ modalView: UIView) {
        toVC.view.transform = CGAffineTransform.identity
        toVC.view.frame = UIScreen.main.bounds
        switch fromVC.sideMenuPosition {
        case .left:
            toVC.view.transform = CGAffineTransform.init(translationX: -40, y: 0)
        case .right:
            toVC.view.transform = CGAffineTransform.init(translationX: toVC.view.bounds.origin.x + 40, y: 0)
        }
        
        fromVC.view.layer.shadowOpacity = 0.7
        containerView.insertSubview(fromVC.view, at: 0)
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            modalView.alpha = 0.5
            switch fromVC.sideMenuPosition {
            case .left:
                fromVC.view.center.x = (fromVC.view.center.x) + UIScreen.main.bounds.width * MenuHelper.menuWidth
            case .right:
                fromVC.view.center.x = (fromVC.view.center.x) - UIScreen.main.bounds.width * MenuHelper.menuWidth
            }
            toVC.view.transform = CGAffineTransform.identity
        }) { (_) in
            let didTransitionComplete = !transitionContext.transitionWasCancelled
            if didTransitionComplete {
                fromVC.sideMenuShowing = true
                transitionContext.completeTransition(didTransitionComplete)
            } else {
                modalView.removeFromSuperview()
                transitionContext.completeTransition(false)
                UIApplication.shared.keyWindow?.addSubview(fromVC.view)
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if _isBeingPresented {
            guard let fromVC = transitionContext.viewController(forKey: .from) as? ELRevealViewController else {return}
            guard let toVC = transitionContext.viewController(forKey: .to) else {return}
            let containerView = transitionContext.containerView
            
            let modalView = UIView()
            fromVC.view.addSubview(modalView)
            fromVC.view.isUserInteractionEnabled = true
            setupModalView(modalView: modalView, fromVC: fromVC)
            
            switch _animationType {
            case .springReveal:
                springRevealPresentAnim(toVC, fromVC, containerView, transitionContext, modalView)
                
            case .flyerReveal:
                addSafeInsets(forVC: fromVC)
                containerView.insertSubview(fromVC.view, at: 0)
                toVC.view.frame = UIScreen.main.bounds
                containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
                modalView.backgroundColor = UIColor.clear
                modalView.alpha = 1
                fromVC.view.layer.shadowOpacity = 0.7
                fromVC.view.layer.shadowOffset = CGSize.zero
                
                let view = UIView()
                view.backgroundColor = UIColor.white
                view.alpha = 0.5
                view.frame = fromVC.view.frame
                view.center = fromVC.view.center
                view.layer.shadowOpacity = 0.4
                view.layer.shadowOffset = CGSize.zero
                view.tag = 10
                
                let view2 = UIView()
                view2.backgroundColor = UIColor.white
                view2.alpha = 0.25
                view2.frame = fromVC.view.frame
                view2.center = fromVC.view.center
                view2.layer.shadowOpacity = 0.2
                view2.layer.shadowOffset = CGSize.zero
                view2.tag = 20
                
                containerView.insertSubview(view, belowSubview: fromVC.view)
                containerView.insertSubview(view2, belowSubview: view)
                
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    let scale: CGFloat = 0.7
                    switch fromVC.sideMenuPosition {
                    case .left:
                        fromVC.view.transform = CGAffineTransform(scaleX: scale, y: scale)
                        fromVC.view.center.x = (fromVC.view.center.x) + (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale
                        
                        view.transform = CGAffineTransform(scaleX: scale, y: scale - 0.03)
                        view.center.x = ((view.center.x) + (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale) - 9
                        
                        view2.transform = CGAffineTransform(scaleX: scale, y: scale - 0.06)
                        view2.center.x = ((view2.center.x) + (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale) - 18
                        
                    case .right:
                        fromVC.view.transform = CGAffineTransform(scaleX: scale, y: scale)
                        fromVC.view.center.x = (fromVC.view.center.x) - (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale
                        
                        view.transform = CGAffineTransform(scaleX: scale, y: scale - 0.03)
                        view.center.x = ((view.center.x) - (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale) + 9
                        
                        view2.transform = CGAffineTransform(scaleX: scale, y: scale - 0.06)
                        view2.center.x = ((view2.center.x) - (UIScreen.main.bounds.width * MenuHelper.menuWidth) * scale) + 18
                    }
                }) { (_) in
                    let didTransitionComplete = !transitionContext.transitionWasCancelled
                    if didTransitionComplete {
                        fromVC.sideMenuShowing = true
                        transitionContext.completeTransition(didTransitionComplete)
                    } else {
                        self.removeSafeInsets(forVC: fromVC, onlyBottom: true)
                        modalView.removeFromSuperview()
                        transitionContext.completeTransition(false)
                        UIApplication.shared.keyWindow?.addSubview(fromVC.view)
                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                    }
                }
                
            }
        } else {
            // IS not being presented, but dismissed
            guard let toVC = transitionContext.viewController(forKey: .to) as? ELRevealViewController  else {return}
            guard let fromVC = transitionContext.viewController(forKey: .from) else {return}
            let modalView = toVC.view.viewWithTag(75)
            switch _animationType {
            case .springReveal:
                if toVC.shouldShowNewViewControllerAnimation {
                    toVC.shouldShowNewViewControllerAnimation = false
                    UIView.animate(withDuration: (transitionDuration(using: transitionContext)/100) * 70, animations: {
                        switch toVC.sideMenuPosition {
                        case .left:
                            toVC.view.center = CGPoint(x: toVC.view.center.x + 15, y: toVC.view.center.y)
                        case .right:
                            toVC.view.center = CGPoint(x: toVC.view.center.x - 15, y: toVC.view.center.y)
                        }
                    }, completion: { (_) in
                        toVC.removeChildViewControllerFromViewController(childViewController: toVC.currentViewController)
                        toVC.addViewControllerAsChildViewController(childViewController: toVC.newViewController!)
                        toVC.newViewController = nil
                        
                        UIView.animate(withDuration: (self.transitionDuration(using: transitionContext) / 100) * 30, animations: {
                            modalView?.alpha = 0
                            toVC.view.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
                            switch toVC.sideMenuPosition {
                            case .left:
                                fromVC.view.transform = CGAffineTransform.init(translationX: -40, y: 0)
                            case .right:
                                fromVC.view.transform = CGAffineTransform.init(translationX: fromVC.view.bounds.origin.x + 40, y: 0)
                                
                            }
                        }) { (_) in
                            let didTransitionComplete = !transitionContext.transitionWasCancelled
                            if didTransitionComplete {
                                toVC.sideMenuShowing = false
                                modalView?.removeFromSuperview()
                            }
                            fromVC.view.transform = CGAffineTransform.identity
                            transitionContext.completeTransition(didTransitionComplete)
                            UIApplication.shared.keyWindow?.addSubview(toVC.view)
                            UIApplication.shared.keyWindow?.makeKeyAndVisible()
                        }
                    })
                } else {
                    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                        modalView?.alpha = 0
                        toVC.view.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
                        switch toVC.sideMenuPosition {
                        case .left:
                            fromVC.view.transform = CGAffineTransform.init(translationX: toVC.view.bounds.origin.x - 40, y: 0)
                        case .right:
                            fromVC.view.transform = CGAffineTransform.init(translationX: toVC.view.bounds.origin.x + 40, y: 0)
                            
                        }
                        
                    }) { (_) in
                        let didTransitionComplete = !transitionContext.transitionWasCancelled
                        if didTransitionComplete {
                            toVC.sideMenuShowing = false
                            modalView?.removeFromSuperview()
                        }
                        fromVC.view.transform = CGAffineTransform.identity
                        transitionContext.completeTransition(didTransitionComplete)
                        UIApplication.shared.keyWindow?.addSubview(toVC.view)
                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                    }
                }
                
            case .flyerReveal:
                let view = transitionContext.containerView.viewWithTag(10)
                let view2 = transitionContext.containerView.viewWithTag(20)
                
                
                if toVC.shouldShowNewViewControllerAnimation {
                    toVC.shouldShowNewViewControllerAnimation = false
                    
                    UIView.animate(withDuration: (transitionDuration(using: transitionContext)/100) * 70, animations: {
                        switch toVC.sideMenuPosition {
                        case .left:
                            toVC.view.center = CGPoint(x: toVC.view.center.x + 15, y: toVC.view.center.y)
                            view?.center = CGPoint(x: view!.center.x + 15, y: view!.center.y)
                            view2?.center = CGPoint(x: view2!.center.x + 15, y: view2!.center.y)
                        case .right:
                            toVC.view.center = CGPoint(x: toVC.view.center.x - 15, y: toVC.view.center.y)
                            view?.center = CGPoint(x: view!.center.x - 15, y: view!.center.y)
                            view2?.center = CGPoint(x: view2!.center.x - 15, y: view2!.center.y)
                        }
                    }, completion: { (_) in
                        toVC.removeChildViewControllerFromViewController(childViewController: toVC.currentViewController)
                        toVC.addViewControllerAsChildViewController(childViewController: toVC.newViewController!)
                        self.removeSafeInsets(forVC: toVC)
                        toVC.newViewController = nil
                        
                        UIView.animate(withDuration: (self.transitionDuration(using: transitionContext) / 100) * 30, animations: {
                            toVC.view.transform = CGAffineTransform.identity
                            toVC.view.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                            
                            view?.transform = CGAffineTransform.identity
                            view?.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                            
                            view2?.transform = CGAffineTransform.identity
                            view2?.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                            
                        }) { (_) in
                            let didTransitionComplete = !transitionContext.transitionWasCancelled
                            if didTransitionComplete {
                                toVC.sideMenuShowing = false
                                modalView?.removeFromSuperview()
                            }
                            transitionContext.completeTransition(didTransitionComplete)
                            UIApplication.shared.keyWindow?.addSubview(toVC.view)
                            UIApplication.shared.keyWindow?.makeKeyAndVisible()
                        }
                    })
                    
                } else {
                    removeSafeInsets(forVC: toVC)
                    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                        toVC.view.transform = CGAffineTransform.identity
                        toVC.view.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                        
                        view?.transform = CGAffineTransform.identity
                        view?.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                        
                        view2?.transform = CGAffineTransform.identity
                        view2?.center = CGPoint.init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                    }) { (_) in
                        let didTransitionComplete = !transitionContext.transitionWasCancelled
                        if didTransitionComplete {
                            toVC.sideMenuShowing = false
                            
                            modalView?.removeFromSuperview()
                        }
                        transitionContext.completeTransition(didTransitionComplete)
                        UIApplication.shared.keyWindow?.addSubview(toVC.view)
                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                    }
                }
                
            }
        }
    }
    
    private func addSafeInsets(forVC vc: ELRevealViewController) {
        if #available(iOS 11.0, *) {
            _safeAreaLayoutGuideExtendedEdges = UIEdgeInsets(top: vc.view.safeAreaLayoutGuide.layoutFrame.origin.y, left: 0.0, bottom: vc.view.safeAreaInsets.bottom, right: 0.0)
            vc.additionalSafeAreaInsets = _safeAreaLayoutGuideExtendedEdges!
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func removeSafeInsets(forVC vc: UIViewController, onlyBottom: Bool = false) {
        if onlyBottom {
            if #available(iOS 11.0, *) {
                _safeAreaLayoutGuideExtendedEdges = UIEdgeInsets(top: (_safeAreaLayoutGuideExtendedEdges?.top)!, left: 0.0, bottom: 0.0, right: 0.0)
                vc.tabBarController?.tabBar.invalidateIntrinsicContentSize()
                vc.additionalSafeAreaInsets = _safeAreaLayoutGuideExtendedEdges!
            } else {
                
                // Fallback on earlier versions
            }
        } else {
            if #available(iOS 11.0, *) {
                _safeAreaLayoutGuideExtendedEdges = nil
                vc.additionalSafeAreaInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func setupModalView(modalView: UIView, fromVC: ELRevealViewController) {
        modalView.backgroundColor = UIColor.darkGray
        modalView.alpha = 0
        modalView.translatesAutoresizingMaskIntoConstraints = false
        modalView.isUserInteractionEnabled = true
        modalView.leadingAnchor.constraint(equalTo: (fromVC.view.leadingAnchor), constant: 0).isActive = true
        modalView.trailingAnchor.constraint(equalTo: (fromVC.view.trailingAnchor), constant: 0).isActive = true
        modalView.bottomAnchor.constraint(equalTo: (fromVC.view.bottomAnchor), constant: 0).isActive = true
        modalView.topAnchor.constraint(equalTo: (fromVC.view.topAnchor), constant: 0).isActive = true
        modalView.tag = 75
        modalView.addGestureRecognizer(UIPanGestureRecognizer(target: fromVC, action: #selector(fromVC.handleClosePanGesture(sender:))))
        modalView.addGestureRecognizer(UITapGestureRecognizer(target: fromVC, action: #selector(fromVC.toggleSideMenu)))
        
    }
}

fileprivate class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

extension UIViewController {
    /**
     Returns the parent ELRevealViewController if the current ViewController is the child. Returns nil if the viewController is not the child. Do not call in viewDidLoad as it will return nil! Use this method to fetch the parent so you can assign the delegate.
     */
    func eLRevealViewController() -> ELRevealViewController? {
        var viewController: UIViewController? = self
        if viewController != nil && viewController is ELRevealViewController {
            return viewController as? ELRevealViewController
        }
        while (!(viewController is ELRevealViewController)) && viewController?.parent != nil {
            viewController = viewController?.parent
        }
        if viewController is ELRevealViewController {
            return viewController as? ELRevealViewController
        }
        if viewController?.presentingViewController != nil && viewController?.presentingViewController is ELRevealViewController {
            return viewController?.presentingViewController as? ELRevealViewController
        }
        return nil
    }
    
    
    
    fileprivate func canPerformSegue(id: String) -> Bool {
        let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject]
        let filtered = segues?.filter({ $0.value(forKey: "identifier") as? String == id })
        guard let count = filtered?.count, count > 0 else {return false}
        return true
    }
    // Just so you dont have to check all the time
    fileprivate func performSegue(id: String, sender: AnyObject?) -> Bool {
        if canPerformSegue(id: id) {
            self.performSegue(withIdentifier: id, sender: sender)
            return true
        }
        return false
    }
}


