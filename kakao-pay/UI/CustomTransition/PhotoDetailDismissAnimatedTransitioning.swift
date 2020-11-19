//
//  PhotoDetailDismissAnimatedTransitioning.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/19.
//

import UIKit

class PhotoDetailDismissAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.3
    let interactionController: PanGestureInteractionController?
    
    init(_ interactionController: PanGestureInteractionController?) {
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        
        let imageView = UIImageView(image: fromVC.currentPhotoImage)
        containerView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let yConstraint = imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)

        let completeTopConstraint = imageView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        completeTopConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            yConstraint,
            completeTopConstraint,
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
        
        fromVC.view.isHidden = true
        fromVC.handleEnterContextClose()
        
        containerView.layoutIfNeeded()
        yConstraint.isActive = false
        
        UIView.animate(withDuration: duration) {
            containerView.layoutIfNeeded()
        } completion: { _ in
            fromVC.view.isHidden = false
            imageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
