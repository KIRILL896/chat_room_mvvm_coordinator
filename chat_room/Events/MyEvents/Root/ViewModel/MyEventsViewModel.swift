//
//  MyEventsViewModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import RxSwift
import RxCocoa






protocol MyEventsViewModelPresentable {
    typealias input = (
        addEvent:Driver<Void>,
        chooseModel:Driver<Event>,
        deleteEvent:Driver<Event>,
        redactEvent:Driver<Event>,
        eventsType:Driver<String>,
        pullRefreshTrigger:Driver<Void>
    )
    typealias output = (
        events: Driver<[MyEventSectionModel]>,
        countTextWarnings: Driver<String>,
        fetching: Driver<Bool>
    )
    typealias ViewModelBuilder = (MyEventsViewModelPresentable.input) -> MyEventsViewModelPresentable
    var input:MyEventsViewModelPresentable.input {get}
    var output:MyEventsViewModelPresentable.output {get}
}


class MyEventsViewModel:MyEventsViewModelPresentable {


    var input: MyEventsViewModelPresentable.input
    
    var output:  MyEventsViewModelPresentable.output
    
    private let eventsService: EventsService
    
    private let disposebag = DisposeBag()
    

    private let allEvents:BehaviorRelay<EventList> = BehaviorRelay<EventList>(value:[])
    
    init(input:MyEventsViewModelPresentable.input, eventsService: EventsService) {
        self.input = input
        self.eventsService = eventsService
        self.output = MyEventsViewModel.output_(input: self.input, service: self.eventsService, allEvents: self.allEvents, bag: disposebag)
    }
}


extension MyEventsViewModel {
    
    func process() {
        self
            .input
            .eventsType
            .asObservable()
            .flatMapLatest { data in
            return self.eventsService.get_all_events(type: data)
            }.map { return $0}
            .map({ [allEvents] in
                allEvents.accept($0)
            })
            .subscribe()
            .disposed(by: disposebag)
   }
    
}

extension MyEventsViewModel {
    
    
    
    static func output_(input:MyEventsViewModelPresentable.input, service: EventsService, allEvents:BehaviorRelay<EventList>, bag:DisposeBag) -> MyEventsViewModelPresentable.output{
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let fetching = activityIndicator.asDriver()
        //let errors = errorTracker.asDriver()
        
        let events = Observable.combineLatest(
            input.eventsType.asObservable(),
            input.pullRefreshTrigger.asObservable()).flatMapLatest { data in
                    return service
                            .get_all_events(type: data.0)
                            .trackActivity(activityIndicator)
                            .trackError(errorTracker)
                            .asDriverOnErrorJustComplete()
            }.map { [allEvents] in
                allEvents.accept($0)
                return $0
            }.map { pull in
                return [MyEventSectionModel(original: MyEventSectionModel.empty(title:pull.count == 0 ? "" : "Сегодня"), items: pull)]
            }
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriver(onErrorJustReturn: [])

        let eventsZeroCountText = Observable
            .combineLatest(
                input.eventsType.asObservable(),
                allEvents)
            .map { type, all in
                let text = type == "all" ? "Общий список событий пуст" : "Вы еще не создали ни одного события"
                let countText = all.count == 0 ? text : ""
                return countText
            }
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriver(onErrorJustReturn: "")
        
        return (events:events, countTextWarnings:eventsZeroCountText, fetching: fetching)
    }
    
    
}

