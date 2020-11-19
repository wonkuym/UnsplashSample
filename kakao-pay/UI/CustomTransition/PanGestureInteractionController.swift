//
//  PanGestureInteractionController.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/20.
//

import UIKit

class PanGestureInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        setupGestureRecognizer(in: viewController.view)
    }
    
    private func setupGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let superview = gestureRecognizer.view?.superview else { return }
        
        let movedPoint = gestureRecognizer.translation(in: superview)
        let progress = max(min(movedPoint.y / 200, 1.0), 0.0)
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController?.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
