//
//  DropPresentingAnimator.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

// Sample Usage:
//let <#animator#> = DropPresentingAnimator()
//
//<#animator#>.animationDuration = 0.75
//<#animator#>.shouldDismissOnTappingOutsideView = true
//<#animator#>.presentingViewSize = CGSize(width: ceil(screenWidth * 0.7), height: 160)
//<#animator#>.overlayViewStyle = .Blurred(UIColor(white: 0.2, alpha: 1.0))
//
//<#presentedViewController#>.modalPresentationStyle = .Custom
//<#presentedViewController#>.transitioningDelegate = animator
//
//presentViewController(<#presentedViewController#>, animated: true, completion: nil)

import UIKit

public class DropPresentingAnimator: Animator {
	
	public override init() {
		super.init()
		animationDuration = 0.5
	}
	
    public var presentingViewSize = CGSize(width: 300, height: 200)
	
	public var overlayViewStyle: OverlayViewStyle = .Blurred(.Dark, UIColor(white: 0.0, alpha: 0.85))
	
	/// Whether presenting view should be dimmed when preseting. If true, tintAdjustmentMode of presenting view will update to .Dimmed.
	public var shouldDimPresentedView: Bool = false
	
	// Tap to dismiss
	public var shouldDismissOnTappingOutsideView: Bool = true
	
	// Drag to dismiss (interactive)
	public var allowDragToDismiss: Bool = false
	
	// MARK: - Private
    private weak var presentationController: DropPresentingPresentationController?
	var interactiveAnimationDraggingRange: CGFloat?
	var interactiveAnimationTransformAngel: CGFloat?
}



// MARK: - UIViewControllerAnimatedTransitioning
extension DropPresentingAnimator {
	public override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		super.animateTransition(transitionContext)
		
		if presenting {
			presentingAnimation(transitionContext)
		} else {
			dismissingAnimation(transitionContext, percentComplete: 0.0)
		}
	}
	
	private func presentingAnimation(transitionContext: UIViewControllerContextTransitioning?) {
		// Necessary setup for presenting
		guard let transitionContext = transitionContext else {
			NSLog("Error: transitionContext is nil")
			return
		}
		
		guard
			let presentedView = self.presentedViewController?.view,
			let containerView = self.containerView else {
				NSLog("Error: Cannot get view from UIViewControllerContextTransitioning")
				return
		}
		
		presentedView.bounds = CGRect(origin: CGPointZero, size: presentingViewSize)
		presentedView.center = CGPoint(x: containerView.bounds.width / 2.0, y: 0 - presentingViewSize.height / 2.0)
		presentedView.transform = CGAffineTransformMakeRotation((CGFloat.random(-15, 15) * CGFloat(M_PI)) / 180.0)
		
		containerView.addSubview(presentedView)
        
		// Presenting animations
		UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: CGFloat.random(0.55, 0.8), initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
			presentedView.center = containerView.center
			presentedView.transform = CGAffineTransformMakeRotation((0.0 * CGFloat(M_PI)) / 180.0)
			}, completion: { finished -> Void in
				transitionContext.completeTransition(finished)
		})
	}
	
	private func dismissingAnimation(transitionContext: UIViewControllerContextTransitioning?, percentComplete: CGFloat) {
		// Necessary setup for dismissing
		guard let transitionContext = transitionContext else {
			NSLog("Error: transitionContext is nil")
			return
		}
		
		guard
			let fromView = self.fromViewController?.view,
			let containerView = self.containerView else {
				NSLog("Error: Cannot get view from UIViewControllerContextTransitioning")
				return
		}
		
		// Dismissing animations
		UIView.animateWithDuration(animationDuration * Double(1.0 - percentComplete), delay: 0.0, usingSpringWithDamping: CGFloat.random(0.55, 0.8), initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
			fromView.center = CGPoint(x: containerView.bounds.width / 2.0, y: containerView.bounds.height + self.presentingViewSize.height)
			fromView.transform = CGAffineTransformMakeRotation((self.interactiveAnimationTransformAngel ?? CGFloat.random(-15, 15) * CGFloat(M_PI)) / 180.0)
			}, completion: { finished -> Void in
				transitionContext.completeTransition(finished)
		})
	}
	
	public override func animationEnded(transitionCompleted: Bool) {
		interactiveAnimationDraggingRange = nil
		interactiveAnimationTransformAngel = nil
		
		// Call super.animationEnded at end to avoid clear transitionContext
		super.animationEnded(transitionCompleted)
	}
}

// MARK: - UIViewControllerInteractiveTransitioning
extension DropPresentingAnimator {
    // MARK: - Interactive Animations
    func updateInteractiveTransition(draggingLocation: CGPoint, percentComplete: CGFloat) {
        if transitionContext == nil {
            NSLog("Error: transitionContext is nil")
        }
        
        self.transitionContext?.updateInteractiveTransition(percentComplete)
        guard let panBeginLocation = presentationController?.panBeginLocation else {
            NSLog("Error: pan begin location is nil")
            return
        }
        
        guard
            let fromView = self.fromViewController?.view,
            let containerView = self.containerView else {
                NSLog("Error: Cannot get view from UIViewControllerContextTransitioning")
                return
        }
        
        guard let interactiveAnimationTransformAngel = interactiveAnimationTransformAngel else {
            NSLog("Error: interactiveAnimationTransformAngel is nil")
            return
        }
        
        let yOffset = draggingLocation.y - panBeginLocation.y
        let beginPoint = containerView.center
        
        fromView.center = CGPoint(x: beginPoint.x, y: beginPoint.y + yOffset)
        fromView.transform = CGAffineTransformMakeRotation(interactiveAnimationTransformAngel.toRadians() *  percentComplete)
    }
    
    func cancelInteractiveTransition(percentComplete: CGFloat) {
        if transitionContext == nil {
            NSLog("Error: transitionContext is nil")
        }
        
        transitionContext?.cancelInteractiveTransition()
        
        if presenting {
            // If cancel presenting, which will dismiss
            presentedViewController?.beginAppearanceTransition(false, animated: true)
        } else {
            // If cancel dismissing, which will present
            presentedViewController?.beginAppearanceTransition(true, animated: true)
        }
        
        guard
            let presentedView = self.presentedViewController?.view,
            let containerView = self.containerView else {
                NSLog("Error: Cannot get view from UIViewControllerContextTransitioning")
                return
        }
        
        // Set a minimum duration, at least has 20% of animation duration.
        let duration = (animationDuration * Double(percentComplete)).normalize(animationDuration * 0.2, animationDuration)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: CGFloat.random(0.55, 0.8), initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
            presentedView.center = containerView.center
            presentedView.transform = CGAffineTransformMakeRotation((0.0 * CGFloat(M_PI)) / 180.0)
        }, completion: { [weak self] finished in
            self?.presentedViewController?.endAppearanceTransition()
            self?.transitionContext?.completeTransition(false)
        })
    }
    
    func finishInteractiveTransition(percentComplete: CGFloat) {
        if transitionContext == nil {
            NSLog("Warning: transitionContext is nil")
        }
        
        self.transitionContext?.finishInteractiveTransition()
        
        // Set percentage completed to less than 1.0 to give a minimum duration
        dismissingAnimation(transitionContext, percentComplete: percentComplete.normalize(0.0, 0.8))
    }
}

extension DropPresentingAnimator {
    public override func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = DropPresentingPresentationController(presentedViewController: presented, presentingViewController: presenting, overlayViewStyle: overlayViewStyle, dropPresentingAnimator: self)
        presentationController.shouldDismissOnTappingOutsideView = shouldDismissOnTappingOutsideView
        presentationController.shouldDimPresentedView = shouldDimPresentedView
        presentationController.allowDragToDismiss = allowDragToDismiss
        
        self.presentationController = presentationController
        
        return presentationController
    }
}
