//
//  NavigationTransition.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import UIKit

class NavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        
        let container = transitionContext.containerView
        if isPresenting {
            container.addSubview(toView)
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        toView.alpha = 0
        UIView.animate(
            withDuration: duration,
            animations: {
                fromView.alpha = 0
                toView.alpha = 1
            },
            completion: { _ in
                fromView.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
