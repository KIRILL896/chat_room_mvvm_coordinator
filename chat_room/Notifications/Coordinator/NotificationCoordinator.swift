//
//  NotificationCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import UIKit
import RxCocoa
import RxSwift

class NotificationCoordinator: BaseCoordinator {
    
    private let router: RouterProtocol
    
    private let bag:DisposeBag = DisposeBag()
    
    init(router: RouterProtocol) {
        self.router = router
    }
    
    override func start() {
        let view = NotificationViewController.instantiate()
        view.viewModelBuilder = { [bag] in
            let viewModel = NotificationViewModel(input: $0, notificationService: NotificationAppService())
    
            viewModel.input.clickAction.asObservable().bind { [weak self] _ in
                self?.showSearch()
            }.disposed(by: bag)
            
            
            return viewModel
        }
        router.push(view, animated: true, onNavigationBack: isCompleted)//pushViewController(view, animated: true)
    }
}




private extension NotificationCoordinator {
    
    func showSearch() {
        
        print("rtrrr")
        //let coordinator = EnterNameCoordinator(router: self.router)
        //self.add(coordinator: coordinator)
        //coordinator.start()
    }

}


