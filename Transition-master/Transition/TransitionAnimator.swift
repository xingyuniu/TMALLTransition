//
//  TransitionAnimator.swift
//  Transition
//
//  Created by Mr yldany on 16/3/21.
//  Copyright © 2016年 YL. All rights reserved.
//

import UIKit

class TransitionAnimator: NSObject {
    
    //MARK:- Properties
    var fromView: UIView
    var coverView: UIView?
    
    //MARK:- init
    init(fromView: UIView) {
        self.fromView = fromView
        super.init()
    }
    
    //MARK:- properties
    var isPresenting: Bool = false
    var transitionContext: UIViewControllerContextTransitioning?
    
}

//MARK:- UIViewControllerTransitioningDelegate
extension TransitionAnimator: UIViewControllerTransitioningDelegate {

    /// 自定义 UIPresentationController 控制器
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return YLPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    /// 弹出动画交由谁管理
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    /// 消失动画交由谁管理
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}


//MARK:- UIViewControllerAnimatedTransitioning
extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    /// 动画执行时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        self.transitionContext = transitionContext
        return 0.75
    }
    
    /// 转场动画逻辑代码
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        /// 执行相关的动画
        isPresenting ? animationForPresentedViewIntransitionContext(transitionContext) : animationForDismissViewIntransitionContext(transitionContext)
    }
}

//MARK:- 动画相关的方法
extension TransitionAnimator {
    
    //MARK:- 弹出的动画
    //MARK:--------------------------------------------------
    private func animationForPresentedViewIntransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        
        // 1.取出 presentingView ,并设置相关属性
        let presentingView = fromView
        presentingView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        let posX: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.5
        let posY: CGFloat = UIScreen.mainScreen().bounds.height
        presentingView.layer.position = CGPoint(x: posX, y: posY)
        transitionContext.containerView()?.addSubview(presentingView)
        
        // 2.取出 presentedView ,并设置相关属性
        let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        transitionContext.containerView()?.addSubview(presentedView)
        presentedView.clipsToBounds = true
        UIApplication.sharedApplication().keyWindow?.addSubview(presentedView)
        
        // 添加cover
        let coverView = UIView(frame: transitionContext.containerView()!.bounds)
        coverView.backgroundColor = UIColor.blackColor()
        coverView.alpha = 0.0;
        transitionContext.containerView()!.insertSubview(coverView, belowSubview: presentedView)
        self.coverView = coverView
        // 3.执行 present 动画
        // 3.1 presentingView
    presentingView.layer.addAnimation(animationForPresentingViewWithContext(transitionContext), forKey: nil)
        
            // 3.2 presentedView
        let animationDuring = transitionDuration(transitionContext)
        presentedView.transform = CGAffineTransformMakeTranslation(0, presentedView.bounds.size.height)
        UIView.animateWithDuration(animationDuring, animations: { () -> Void in
            coverView.alpha = 0.5
            presentedView.transform = CGAffineTransformIdentity
            }, completion: nil)
       
    }
    
    
    //MARK:- 消失的动画
    //MARK:--------------------------------------------------
    /// dismiss动画
    private func animationForDismissViewIntransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. presentedView的动画
        let toView = self.fromView
        toView.layer.addAnimation(self.animationForPresentingViewWithContext(transitionContext), forKey: "dismiss_ani")
        
        // 2. dismissView 的动画
        let dismissView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            
            dismissView?.transform = CGAffineTransformMakeTranslation(0, dismissView!.bounds.size.height)
            self.coverView?.alpha = 0
            }) { (finished) -> Void in
        }
    }
    
    /// 设置 PresentingView 的转场动画
    private func animationForPresentingViewWithContext(context: UIViewControllerContextTransitioning)-> CAAnimation {
        
        let animationDuring = transitionDuration(context)
        
        // 旋转
        let translateAnimation = CAKeyframeAnimation(keyPath: "transform")
        var baseTransform = CATransform3DIdentity
        baseTransform.m34 = -1 / 800
        translateAnimation.values = [NSValue(CATransform3D: baseTransform),
            NSValue(CATransform3D: CATransform3DRotate(baseTransform, CGFloat(M_PI_2 * 0.0125), 1, 0, 0)),
            NSValue(CATransform3D: CATransform3DRotate(baseTransform, CGFloat(M_PI_2 * 0.025), 1, 0, 0)),
            NSValue(CATransform3D: CATransform3DRotate(baseTransform, CGFloat(M_PI_2 * 0.0125), 1, 0, 0)),
            NSValue(CATransform3D: baseTransform)]
        translateAnimation.duration = animationDuring
        translateAnimation.removedOnCompletion = false
        translateAnimation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        translateAnimation.autoreverses = false
        translateAnimation.fillMode = "forwards"
        // 缩放
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = isPresenting ? 1.0 : 0.95
        scaleAnimation.toValue = isPresenting ? 0.95 : 1.0
        scaleAnimation.duration = animationDuring
        scaleAnimation.removedOnCompletion = false
        scaleAnimation.autoreverses = false
        scaleAnimation.fillMode = "forwards"
        
        // 组动画
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = animationDuring
        groupAnimation.removedOnCompletion = false
        groupAnimation.autoreverses = false
        groupAnimation.delegate = self
        groupAnimation.fillMode = "forwards"
        groupAnimation.animations = [translateAnimation, scaleAnimation]
        
        return groupAnimation
    }

    /// 动画结束的代理方法
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        transitionContext!.completeTransition(true)
        if anim == fromView.layer.animationForKey("dismiss_ani") {
            self.coverView?.removeFromSuperview()
            fromView.removeFromSuperview()
        }
    }
    
}



