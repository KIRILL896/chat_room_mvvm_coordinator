//
//  EventInfoCoordinator.swift
//  Liveroom
//
//  Created by отмеченные on 12.04.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class EventInfoCoordinator:BaseCoordinator {
    
    private let router:RouterProtocol
    
    private let bag:DisposeBag = DisposeBag()
    
    var viewModel:EventInfoViewModel!
    
    init(router:RouterProtocol) {
        self.router = router
    }
    
    override func start() {
        let view = EventInfoViewController()
        view.viewModelBuilder = {  [bag] in
            self.viewModel = EventInfoViewModel(input: $0,
                            eventsService: EventsService()
            )
 
            return self.viewModel
        }
        router.presenTation(view, animated: true, onDismiss: isCompleted)
    }
}



extension EventInfoCoordinator {

    func shareEvent() {

    }
    
    func copiLink() {

    }
    
    func addToCalendar() {

    }
    
    func followToEvent() {

    }
}
