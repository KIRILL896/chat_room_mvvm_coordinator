//
//  MyEventsCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class MyEventsCoordinator:BaseCoordinator {
    
    private let router:RouterProtocol
    
    private let bag:DisposeBag = DisposeBag()
    
    var viewModel:MyEventsViewModel!
    
    init(router:RouterProtocol) {
        self.router = router
    }
    
    override func start() {
        let view = MyEventsViewController.instantiate()
        view.viewModelBuilder = {  [bag] in
            self.viewModel = MyEventsViewModel(input: $0,
                            eventsService: EventsService()
            )
            self.viewModel.input.addEvent.drive { [weak self] _ in
                self?.showEvent()
            }.disposed(by:bag)
            
            self.viewModel.input.chooseModel.drive { [weak self] model in
                self?.showEventInfo()
            }.disposed(by:bag)
            
            return self.viewModel
        }
        router.push(view, animated:true, onNavigationBack: isCompleted)
    }
}



extension MyEventsCoordinator {

    func showEvent() {
        let EventCoordinator_ = EventCoordinator(router:self.router)
        self.add(coordinator: EventCoordinator_)
        EventCoordinator_.isCompleted = { [weak self, weak EventCoordinator_, weak viewModel] in
            guard let coordinator = EventCoordinator_ else {return}
            self?.remove(coordinator:coordinator)
            viewModel?.process()
        }
        EventCoordinator_.start()
    }
    
    func showEventInfo() {        
//        let EventInfoCoordinator_ = EventInfoCoordinator(router:self.router)
//        self.add(coordinator: EventInfoCoordinator_)
//        EventInfoCoordinator_.isCompleted = { [weak self, weak EventInfoCoordinator_, weak viewModel] in
//            guard let coordinator = EventInfoCoordinator_ else {return}
//            self?.remove(coordinator:coordinator)
//            viewModel?.process()
//        }
//        EventInfoCoordinator_.start()
    }
    
}
