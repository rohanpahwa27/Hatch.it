

import UIKit

public protocol AURUnlockSliderDelegate: class {
    
    func unlockSliderDidUnlock(_ slider:AURUnlockSlider)
}

open class AURUnlockSlider: UIView {
    
    final public weak var delegate:AURUnlockSliderDelegate?
    
    final public var sliderText = "Slide to Unlock"
    final public var sliderTextColor:UIColor = UIColor.lightGray
    final public var sliderTextFont:UIFont = UIFont(name: "HelveticaNeue-Thin", size: 15.0)!
    final public var sliderCornerRadius:CGFloat = 3.0
    final public var sliderColor = UIColor.clear
    final public var sliderBackgroundColor:UIColor = UIColor.clear
    
    final fileprivate let sliderContainer = UIView(frame: CGRect.zero)
    final fileprivate let sliderView = UIView(frame: CGRect.zero)
    final fileprivate let sliderViewLabel = UILabel(frame: CGRect.zero)
    final fileprivate var isCurrentDraggingSlider = false
    final fileprivate var lastDelegateFireOffset = CGFloat(0)
    final fileprivate var touchesBeganPoint = CGPoint.zero
    final fileprivate var valueChangingTimer:Timer?
    final fileprivate let sliderPanGestureRecogniser = UIPanGestureRecognizer()
    final fileprivate let dynamicButtonAnimator = UIDynamicAnimator()
    final fileprivate var snappingBehavior:SliderSnappingBehavior?
    
    
    public override init(frame:CGRect) {
        
        super.init(frame: frame)
        
        
        setupView()
        setNeedsLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setupView()
        setNeedsLayout()
    }
    
    fileprivate func setupView() {
        
        sliderContainer.backgroundColor = backgroundColor
        
        sliderContainer.addSubview(sliderView)
        
        sliderViewLabel.isUserInteractionEnabled = false
        sliderViewLabel.textAlignment = NSTextAlignment.center
        sliderViewLabel.textColor = sliderTextColor
        sliderView.addSubview(sliderViewLabel)
        
        sliderPanGestureRecogniser.addTarget(self, action: NSSelectorFromString("handleGesture:"))
        sliderView.addGestureRecognizer(sliderPanGestureRecogniser)
        
        sliderContainer.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        addSubview(sliderContainer)
        clipsToBounds = true
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        sliderContainer.frame = frame
        sliderContainer.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        sliderContainer.backgroundColor = sliderBackgroundColor
        
        sliderView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
        sliderView.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        sliderView.backgroundColor = sliderColor
        
        sliderViewLabel.frame = CGRect(x: 0.0, y: 0.0, width: sliderView.bounds.size.width, height: sliderView.bounds.size.height)
        sliderViewLabel.center = CGPoint(x: sliderViewLabel.bounds.size.width * 0.5, y: sliderViewLabel.bounds.size.height * 0.5)
        sliderViewLabel.backgroundColor = sliderColor
        sliderViewLabel.font = sliderTextFont
        sliderViewLabel.text = sliderText
        
        layer.cornerRadius = sliderCornerRadius
    }
    
    final func handleGesture(_ sender: UIGestureRecognizer) {
        
        if sender as NSObject == sliderPanGestureRecogniser {
            
            switch sender.state {
                
            case .began:
                isCurrentDraggingSlider = true
                touchesBeganPoint = sliderPanGestureRecogniser.translation(in: sliderView)
                if dynamicButtonAnimator.behaviors.count != 0 {
                    dynamicButtonAnimator.removeBehavior(snappingBehavior!)
                }
                
                lastDelegateFireOffset = ((touchesBeganPoint.x + touchesBeganPoint.x) * 0.40)
                
            case .changed:
                valueChangingTimer?.invalidate()
                let translationInView = sliderPanGestureRecogniser.translation(in: sliderView)
                let translatedCenterX:CGFloat = (bounds.size.width * 0.5) + ((touchesBeganPoint.x + translationInView.x))
                sliderView.center = CGPoint(x: translatedCenterX, y: sliderView.center.y);
                lastDelegateFireOffset = translatedCenterX
                
            case .ended:
                
                fallthrough
                
            case .failed:
                
                fallthrough
                
            case .cancelled:
                var point: CGPoint?
                if sliderView.frame.origin.x > sliderContainer.center.x {
                    delegate?.unlockSliderDidUnlock(self)
                    point = CGPoint(x: bounds.size.width * 1.5, y: bounds.size.height * 0.5)
                } else {
                    point = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
                }
                
                snappingBehavior = SliderSnappingBehavior(item: sliderView, snapToPoint: point!)
                lastDelegateFireOffset = sliderView.center.x
                dynamicButtonAnimator.addBehavior(snappingBehavior!)
                isCurrentDraggingSlider = false
                lastDelegateFireOffset = center.x
                valueChangingTimer?.invalidate()
                
            case .possible:
                
                print("possible")
            }
        }
    }
}

final class SliderSnappingBehavior: UIDynamicBehavior {
    
    var snappingPoint:CGPoint
    init(item: UIDynamicItem, snapToPoint point: CGPoint) {
        
        let dynamicItemBehavior:UIDynamicItemBehavior  = UIDynamicItemBehavior(items: [item])
        dynamicItemBehavior.allowsRotation = false
        
        let snapBehavior:UISnapBehavior = UISnapBehavior(item: item, snapTo: point)
        snapBehavior.damping = 1
        
        snappingPoint = point
        
        super.init()
        
        addChildBehavior(snapBehavior)
        addChildBehavior(dynamicItemBehavior)
        
    }
    
    
}
