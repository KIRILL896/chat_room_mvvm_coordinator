//
//  EventInfoPresentationController.swift
//  Liveroom
//
//  Created by отмеченные on 12.04.2021.
//

import UIKit

class EventInfoPresentationController: UIPresentationController {
    
    let backView: UIView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        backView = UIView()
        backView.backgroundColor = .backgroundModal
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        backView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height - 410),
               size: CGSize(width: self.containerView!.frame.width, height: 410))
    }
    
    override func presentationTransitionWillBegin() {
        self.backView.alpha = 0
        self.containerView?.addSubview(backView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.backView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.backView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.backView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 18)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        backView.frame = containerView!.bounds
    }
    
    @objc func dismissController(){
        
        
        
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}


