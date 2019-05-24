import Foundation
import UIKit

class ELKeyboardHelper {
    
    private init() {
        bindToKeyboard()
    }
    
    static let instance = ELKeyboardHelper()
    
    private weak var registeredObject: UIView? {
        didSet {
            debugPrint("Keyboardhelper registeredObject changed into \(String(describing: registeredObject))")
        }
    }
    
    private var keyboardFrame: CGRect?
    private var curve: UInt?
    private var duration: Double?
    private var originalInsets: UIEdgeInsets?
    
    public func registerObject(view: UIView) {
        registeredObject = view
    }
    
    public func deRegisterObject() {
        registeredObject = nil
    }
    
    private func bindToKeyboard () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func reCalculate() {
        guard let registeredObject = registeredObject, let endingFrame = keyboardFrame, let curve = curve, let duration = duration else {return}


        let parentView = findParentView(forView: registeredObject)
        let superFrame = registeredObject.convert(registeredObject.frame, to: parentView)
        let convertedKeyboardFrame = parentView.convert(endingFrame, from: nil)
        
        if let scrollView = parentView as? UIScrollView {
            parentViewAsScrollView(notification: nil, scrollView: scrollView, superFrame: superFrame, convertedKeyboardFrame: convertedKeyboardFrame)
        }

//
//        if endingFrame.minY <= superFrame.maxY + 20 {
//            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
//                parentView.transform = CGAffineTransform(translationX: 0, y: endingFrame.minY - superFrame.maxY - 20)
//            },completion: nil)
//        } else {
//            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
//                parentView.transform = CGAffineTransform.identity
//            },completion: nil)
//        }
    }
    
    @objc private func keyboardWillChange(_ notification : NSNotification) {
        duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        guard let registeredObject = registeredObject, let endingFrame = keyboardFrame, let duration = duration, let curve = curve else {return}
        
        let parentView = findParentView(forView: registeredObject)
        let superFrame = registeredObject.convert(registeredObject.frame, to: parentView)
        let convertedKeyboardFrame = parentView.convert(endingFrame, from: nil)
        
        if let scrollView = parentView as? UIScrollView {
            parentViewAsScrollView(notification: notification, scrollView: scrollView, superFrame: superFrame, convertedKeyboardFrame: convertedKeyboardFrame)
return
        } else if let tableView = parentView as? UITableView {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + (endingFrame.minY - superFrame.maxX - 20)), animated: true)
            return
        }
        
        if endingFrame.minY <= superFrame.maxY + 20 {
            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
                
                parentView.transform = CGAffineTransform(translationX: 0, y: endingFrame.minY - superFrame.maxY - 20)
            },completion: nil)
        } else {
            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
                parentView.transform = CGAffineTransform.identity
            },completion: nil)
        }
    }


    private func parentViewAsScrollView(notification: NSNotification?, scrollView: UIScrollView, superFrame: CGRect, convertedKeyboardFrame: CGRect) {
        if notification?.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInsetAdjustmentBehavior = .automatic
            scrollView.contentInset = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: scrollView.contentInset.bottom - convertedKeyboardFrame.height, right: scrollView.contentInset.right)
        } else {
            
//            let calc = convertedKeyboardFrame.minY - superFrame.maxY
            
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: convertedKeyboardFrame.height, right: scrollView.contentInset.right)
            scrollView.scrollRectToVisible(superFrame, animated: true)
        }
    }
}

private func findParentView(forView view: UIView) -> UIView {
    if view.isKind(of: UIScrollView.self) {
        return view
    }
    
    if view.superview != nil {
        return findParentView(forView: view.superview!)
    } else {
        return view
    }
    }
