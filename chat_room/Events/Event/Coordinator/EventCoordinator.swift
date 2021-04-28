//
//  EventCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class EventCoordinator:BaseCoordinator {
    
    private let router:RouterProtocol
    
    private let bag:DisposeBag = DisposeBag()
    
    init(router:RouterProtocol) {
        self.router = router
    }
    
    override func start() {
        let view = EventViewController.instantiate()
        view.viewModelBuilder = { [bag] in
            let viewModel = EventViewModel(input: $0, eventsService: EventsService(), subscribeService: SubscriptionsService())
            viewModel.backAction.asObservable().bind { [weak self] _ in
                self?.router.back(true)
            }.disposed(by: bag)
            
          
            
            return viewModel
        }
        //router.push(view, animated: true, onNavigationBack: isCompleted)
        router.present(view, animated: true, onDismiss: isCompleted)
    }
}



extension EventCoordinator {
    
    func showSubscribesrsList() {
        let subCoordinator_ = SubsribersListCoordinator(router:self.router)
        self.add(coordinator: subCoordinator_)
        subCoordinator_.isCompleted = { [weak self, weak subCoordinator_] in
            guard let coordinator = subCoordinator_ else {return}
            self?.remove(coordinator:coordinator)
        }
        subCoordinator_.start()
    }
}

