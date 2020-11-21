//
//  PhotoDetailPresentable.swift
//  kakao-pay
//
//  Created by wonkyum kim on 2020/11/20.
//

import UIKit

protocol PhotoDetailPresentable {
}

extension PhotoDetailPresentable where Self: UITableViewController, Self: UIViewControllerTransitioningDelegate {
    func showDetail(_ enterContext: DetailEnterContext) {
        let detailVC = PhotoDetailViewController()
        detailVC.enterContext = enterContext
        detailVC.modalPresentationStyle = .custom
        detailVC.transitioningDelegate = self
        
        present(detailVC, animated: true, completion: nil)
    }
    
    fileprivate func makePresentAnimatedTransitioning() -> UIViewControllerAnimatedTransitioning? {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow,
              let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? PhotoCell,
              let selectedPhotoView = selectedCell.photoView,
              let selectedImage = selectedPhotoView.image else {
            return nil
        }
        
        let beginImageFrame = selectedPhotoView.convert(selectedPhotoView.bounds, to: nil)
        return PhotoDetailPresentAnimatedTransitioning(selectedImage, beginImageFrame: beginImageFrame)
    }
    
    fileprivate func interactionControllerFromAnimator(_ animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? PhotoDetailDismissAnimatedTransitioning,
              let interactionController = animator.interactionController,
              interactionController.interactionInProgress
        else {
            return nil
        }
        return interactionController
    }
}

// MARK: - PhotosViewController
extension PhotosViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PhotoDetailPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makePresentAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let detailVC = dismissed as? PhotoDetailViewController else { return nil }
        return PhotoDetailDismissAnimatedTransitioning(detailVC.panGestureInteractionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionControllerFromAnimator(animator)
    }
}

// MARK: - PhotoSearchResultsController
extension PhotoSearchResultsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PhotoDetailPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return makePresentAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let detailVC = dismissed as? PhotoDetailViewController else { return nil }
        return PhotoDetailDismissAnimatedTransitioning(detailVC.panGestureInteractionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionControllerFromAnimator(animator)
    }
}
