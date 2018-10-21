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
    
    public func registerObject(view: UIView) {
        registeredObject = view
    }
    
    public func deRegisterObject() {
        registeredObject = nil
    }
    
    private func bindToKeyboard () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    @objc private func keyboardWillChange(_ notification : NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let endingFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        guard let registeredObject = registeredObject else {return}
        let parentView = findParentView(forView: registeredObject)
        let superFrame = registeredObject.convert(registeredObject.frame, to: parentView)
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

}

private func findParentView(forView view: UIView) -> UIView {
    if view.superview != nil {
        return findParentView(forView: view.superview!)
    } else {
        return view
    }
}
