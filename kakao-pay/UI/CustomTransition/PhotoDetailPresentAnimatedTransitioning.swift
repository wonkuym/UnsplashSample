//
//  PhotoDetailPresentAnimatedTransitioning.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/19.
//

import UIKit

class PhotoDetailPresentAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval = 0.3
    private let selectedImage: UIImage
    private let beginImageFrame: CGRect
    
    init(_ selectedImage: UIImage, beginImageFrame: CGRect) {
        self.selectedImage = selectedImage
        self.beginImageFrame = beginImageFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let selectedImageView = UIImageView(image: selectedImage)
        selectedImageView.frame = beginImageFrame
        containerView.addSubview(selectedImageView)
        
        toVC.view.isHidden = true
        UIView.animate(withDuration: duration) {
            selectedImageView.center = containerView.center
        } completion: { _ in
            toVC.view.isHidden = false
            selectedImageView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
