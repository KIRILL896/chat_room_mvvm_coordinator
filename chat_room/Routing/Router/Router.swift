//
//  Router.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit

final class Router: NSObject, RouterProtocol {

    public let navigationContoller:UINavigationController
    private var closures:[String:NavigationBackClosure] = [:]
 
    init (navigationController:UINavigationController) {
        self.navigationContoller = navigationController
        super.init()
        self.navigationContoller.delegate = self
    }
    
    
    func presenTation(_ drawable: Drawable, animated: Bool, onDismiss closure: NavigationBackClosure?) {
        guard let viewController = drawable.viewController else {return}
        if let closure = closure {
            closures.updateValue(closure, forKey:viewController.description)
        }
        viewController.presentationController?.delegate = self
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        navigationContoller.present(viewController, animated: true, completion: nil)

    }
    
    
//    func showCreateView() {
//        let createView = CreateView()
//        createView.createRoomAction = showCreateRoomView
//        createView.createEventAction = showCreateEvent
//        createView.createCommunityAction = showCreateCommunity
//        createView.modalPresentationStyle = .custom
//        createView.transitioningDelegate = self
//        self.present(createView, animated: true, completion: nil)
//    }
    
    func present(_ drawable: Drawable, animated: Bool, onDismiss closure: NavigationBackClosure?) {
        guard let viewController = drawable.viewController else {return}
        if let closure = closure {
            closures.updateValue(closure, forKey:viewController.description)
        }
        navigationContoller.present(viewController, animated: true, completion: nil)
        viewController.presentationController?.delegate = self
    }
    
    func push(_ drawable: Drawable, animated: Bool, onNavigationBack: NavigationBackClosure?) {
        guard let viewController = drawable.viewController else {return}
        if let closure = onNavigationBack {
            closures.updateValue(closure, forKey:viewController.description)
        }
        navigationContoller.pushViewController(viewController, animated: true)
    }
    
    func pop(_ isAnimated: Bool) {
        navigationContoller.popViewController(animated: isAnimated)
    }
    
    func back(_ isAnimated: Bool) {
        
        guard let closure = closures.removeValue(forKey: navigationContoller.presentedViewController!.description) else {
            return
        }
        
        closure()
        
        navigationContoller.dismiss(animated: true, completion: nil)
        
    }
    
    func executeClosure(_ viewController:UIViewController) {
        guard let closure = closures.removeValue(forKey: viewController.description) else {
            return
        }
        
        closure()
    }
}


extension Router:UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        executeClosure(presentationController.presentedViewController)
    }
    
    
    
    func presentationControllerDidAttemptToDismiss(_ presentationController:UIPresentationController) {
        
    }
    
    


    
    
}


extension Router:UINavigationControllerDelegate {

    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        
        guard let previosuViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {return}
        guard !navigationController.viewControllers.contains(previosuViewController) else {return}
        executeClosure(previosuViewController)
    }
}


extension Router: UIViewControllerTransitioningDelegate {
    

    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is CreateRoomView {
            return CreateRoomPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is ChoiceOfInterlocutorsView {
            return ChoiceOfInterlocutorsPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is InputRoomNameView {
            return InputRoomNameViewPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is CreateView {
            return CreateViewPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is EventInfoViewController {
            let controller = EventInfoPresentationController(presentedViewController: presented, presenting: presenting)
            controller.delegate = self
            return controller
        } else {
            return UIPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
    

}
