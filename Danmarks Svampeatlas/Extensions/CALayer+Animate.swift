import UIKit

extension CALayer {
    
    public func animate() -> CALayerAnimate {
        return CALayerAnimate(layer: self)
    }
}

public class CALayerAnimate {
    
    private var animations: [String: CAAnimation]
    private var duration: CFTimeInterval
    let layer: CALayer
    
    init(layer: CALayer) {
        self.animations = [String: CAAnimation]()
        self.duration = 0.25 // second
        self.layer = layer
    }
    
    public func shadowOpacity(shadowOpacity: Float) -> CALayerAnimate {
        let key = "shadowOpacity"
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = layer.shadowOpacity
        animation.toValue = shadowOpacity
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animations[key] = animation
        return self
    }
    
//    public func shadowRadius(shadowRadius: CGFloat) -> CALayerAnimate {
//        let key = "shadowRadius"
//        let animation = CABasicAnimation(keyPath: key)
//        animation.fromValue = layer.shadowRadius
//        animation.toValue = shadowRadius
//        animation.isRemovedOnCompletion = false
//        animation.fillMode = CAMediaTimingFillMode.forwards
//        animations[key] = animation
//        return self
//    }
//
//    public func shadowOffsetX(shadowOffsetX: CGFloat) -> CALayerAnimate {
//        let key = "shadowOffset"
//
//        var toValue: CGSize
//        if let currentAnimation = animations[key] as? CABasicAnimation, let currentValue = currentAnimation.toValue {
//            toValue = currentValue as! CGSize
//        } else {
//            toValue = CGSizeZero
//        }
//        toValue.width = shadowOffsetX
//
//        let animation = CABasicAnimation(keyPath: key)
//        animation.fromValue = NSValue(CGSize: layer.shadowOffset)
//        animation.toValue = NSValue(CGSize: toValue)
//        animation.removedOnCompletion = false
//        animation.fillMode = kCAFillModeForwards
//        animations[key] = animation
//        return self
//    }
//
//    public func shadowOffsetY(shadowOffsetY: CGFloat) -> CALayerAnimate {
//        let key = "shadowOffset"
//
//        var toValue: CGSize
//        if let currentAnimation = animations[key] as? CABasicAnimation, let currentValue = currentAnimation.toValue {
//            toValue = currentValue.CGSizeValue()
//        } else {
//            toValue = CGSizeZero
//        }
//        toValue.height = shadowOffsetY
//
//        let animation = CABasicAnimation(keyPath: key)
//        animation.fromValue = NSValue(CGSize: layer.shadowOffset)
//        animation.toValue = NSValue(CGSize: toValue)
//        animation.removedOnCompletion = false
//        animation.fillMode = kCAFillModeForwards
//        animations[key] = animation
//        return self
//    }
    
    public func duration(duration: CFTimeInterval) -> CALayerAnimate {
        self.duration = duration
        return self
    }
    
    public func start() {
        for (key, animation) in animations {
            animation.duration = duration
            layer.removeAnimation(forKey: key)
            layer.add(animation, forKey: key)
        }
    }
}
