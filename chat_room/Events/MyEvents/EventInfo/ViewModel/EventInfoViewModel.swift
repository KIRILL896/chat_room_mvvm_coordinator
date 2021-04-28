//
//  EventInfoViewModel.swift
//  Liveroom
//
//  Created by отмеченные on 12.04.2021.
//

import RxSwift
import RxCocoa

protocol EventInfoViewModelPresentable {
    typealias input = (
        addEvent:Driver<Void>,
        chooseModel:Driver<Event>,
        deleteEvent:Driver<Event>,
        redactEvent:Driver<Event>,
        eventsType:Driver<String>
    )
    typealias output = (
    )
    typealias ViewModelBuilder = (EventInfoViewModelPresentable.input) -> EventInfoViewModelPresentable
    var input:EventInfoViewModelPresentable.input {get}
    var output:EventInfoViewModelPresentable.output {get}
}


class EventInfoViewModel:EventInfoViewModelPresentable {

    var input: EventInfoViewModelPresentable.input
    
    var output:  EventInfoViewModelPresentable.output
    
    private let eventsService: EventsService
    
    private let disposebag = DisposeBag()
    
    
    private let EventInfo:BehaviorRelay<EventList> = BehaviorRelay<EventList>(value:[])

    private let allEvents:BehaviorRelay<EventList> = BehaviorRelay<EventList>(value:[])
    
    init(input:EventInfoViewModelPresentable.input, eventsService: EventsService) {
        self.input = input
        self.eventsService = eventsService
        self.output = EventInfoViewModel.output_(input: self.input, bag: disposebag)
        self.process()
    
    }
}

extension EventInfoViewModel {
    
     func process() {
        

    }
    
    
    static func output_(input:EventInfoViewModelPresentable.input, bag:DisposeBag) -> EventInfoViewModelPresentable.output{
  
        
        return ()
    }
    
    
}
