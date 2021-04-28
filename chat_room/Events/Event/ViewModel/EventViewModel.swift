//
//  EventViewModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import RxSwift
import RxCocoa


protocol EventViewModelPresentable {
    typealias input = (
        cancel:Driver<Void>,
        create:Driver<Void>,
        eventName:Driver<String>,
        time:Driver<String>,
        eventDescription:Driver<String>,
        addGuests:Driver<Void>,
        tableModelSelected:Driver<Speaker>,
        deleteTableItem:Driver<Subscriber_>,
        selectedSubscriber:Driver<Subscriber_>,
        searchText:Driver<String>,
        avatarPicker:Driver<UIImage>
    )
    typealias output = (
        canCreate:Driver<Bool>,
        textCount: Driver<String>,
        selectedSubscirbers: Driver<[TopSpeakersSectionModel]>,
        subscribers:Driver<[SubscribersSectionModel]>,
        textBlock:Driver<String>
    )
    typealias ViewModelBuilder = (EventViewModelPresentable.input) -> EventViewModelPresentable
    var input:EventViewModelPresentable.input {get}
    var output:EventViewModelPresentable.output {get}
    var backAction:PublishSubject<Void> {get set}
    
}


class EventViewModel:EventViewModelPresentable {
    var backAction: PublishSubject<Void>
    
    var input: EventViewModelPresentable.input
    
    var output:  EventViewModelPresentable.output
    
    var subjects:BehaviorRelay<[Speaker_]> = BehaviorRelay<[Speaker_]>(value:[])
    
    private let eventsService: EventsService
    private let keyChainService: KeychainService
    private var defaultsService: DefaultsServiceProtocol = DI.resolve()
    private let subscribeService:SubscriptionsService
    
    
    private let subscribers:BehaviorRelay<[Subscriber_]> = BehaviorRelay<[Subscriber_]>(value:[])

    
    let bag = DisposeBag()
    
    init(input:EventViewModelPresentable.input, eventsService: EventsService, subscribeService:SubscriptionsService) {
        self.input = input
        self.backAction = PublishSubject<Void>()
        self.eventsService = eventsService
        self.subscribeService = subscribeService
        self.keyChainService = KeychainService()
        self.output = EventViewModel.output_(input: self.input, backAction: backAction, bag: bag, service: self.eventsService,  user:defaultsService.user!, subjects:subjects, subscribers: self.subscribers)
        self.process()
    }
}

private extension EventViewModel {
    
    func process() {
        
        self
            .subscribeService
            .get_subscribtions()
            .map({ [subscribers] values in
                
                let modelse = values.map {
                    return Subscriber_(model: $0)
                }
                
                subscribers.accept(modelse)
            })
            .subscribe()
            .disposed(by: bag)
        
    }
    
    
    static func output_(input:EventViewModelPresentable.input, backAction:PublishSubject<Void>, bag:DisposeBag, service:EventsService, user:User, subjects:BehaviorRelay<[Speaker_]>, subscribers:BehaviorRelay<[Subscriber_]>) -> EventViewModelPresentable.output{
    
        let credentials = Observable.combineLatest(input.eventName.asObservable(), input.eventDescription.asObservable(), input.time.asObservable())
        
        let canContinue = credentials.asObservable()
            .map { name, desc, time -> Bool in
                if name.isEmpty { return false }
                if desc.isEmpty { return false}
                if time.isEmpty { return false}
                if name == "" { return false }
                if desc == "" { return false}
                if time == "" { return false}
                return true
            }.asDriver(onErrorJustReturn: false)
        
        
        let searchTextObservable =  input
                                    .searchText
                                    .debounce(.milliseconds(300))
                                    .distinctUntilChanged()
                                    .skip(0)
                                    .asObservable()
                                    .share(replay: 1, scope: .whileConnected)
        
        
        let textBlock = input
            .eventDescription
            .scan("") { (previous, new) -> String in
                if new.count > 255 {
                    return previous 
                } else {
                    return new
                }
            }.asDriver()
        
        
        let textDescDriver = input
            .eventDescription
            .asObservable()
            .map { value in
                return value.count > 0 ? String(Int(255) - value.count) + " символов осталось" : "255 символов осталось"
            }.asDriver(onErrorJustReturn: "")
        
        
        input
            .selectedSubscriber
            .asObservable()
            .withLatestFrom(subscribers) {return ($0, $1)}
            .map { selected, values in
                var c = values
                guard let index = values.firstIndex(where: { (item) -> Bool in
                    item.id == selected.id && item.firstname == selected.firstname // test if this is the item you're looking for
                }) else {return}
                c[index].selected = !c[index].selected
                subscribers.accept(c)
            }.subscribe().disposed(by: bag)
        
        
        
        let subscribers_ = Observable.combineLatest(searchTextObservable, subscribers).map { searchKey, values in
                return values.filter { (value) -> Bool in
                     value.firstname!.lowercased().replacingOccurrences(of: " ", with: "").hasPrefix(searchKey.lowercased()) || value.lastname!.lowercased().replacingOccurrences(of: " ", with: "").hasPrefix(searchKey.lowercased())
                }
        }.map {
            return [SubscribersSectionModel(items: $0, title: "", id: "")]
        }.asDriver(onErrorJustReturn: [])
        

        
        input
            .deleteTableItem
            .asObservable()
            .withLatestFrom(subscribers) {return ($0, $1)}
            .map { item, values in
                var c = values
                for (i, value) in c.enumerated() {
                    if value.id == item.id {
                        c[i].selected = false
                        break
                    }
                }            
                subscribers.accept(c)
            }.subscribe().disposed(by: bag)
        
        
        let selectedSubscirbers = subscribers.asObservable().map { values  -> [TopSpeakersSectionModel] in
            let sorted =  values.filter { return $0.selected == true }
            return [TopSpeakersSectionModel(items: sorted, title: "", id: "")]
        }.asDriver(onErrorJustReturn: [])
        
        
        input
            .create
            .asObservable()
            .withLatestFrom(Observable.combineLatest(credentials, selectedSubscirbers.asObservable()).asObservable())
            .map { data in
                return data
            }
            .flatMapLatest { data_ -> Observable<Bool> in
                let data = data_.0
                let speak = data_.1[0]
                var speakers_ = speak.items.map { user in
                    return Speaker(id: user.id, firstname: user.firstname, lastname: user.lastname, photo: user.photo)
                }
                speakers_.append(Speaker(id: user.id, firstname: user.firstname, lastname: user.lastname, photo: user.photo))
                let speakers_id = speakers_.filter { return $0.id != nil}.map {$0.id!}
                let request = CreateEventRequest(id: nil, name: data.0, description: data.1, community_id: nil, time_zone: "GMT+1", top_speakers: speakers_, date: Date().toString(), speakers: speakers_id)
                return service.createEvent(map: request).asObservable().map { return $0}
            }.bind { data in
                print("data is \(data)")
                backAction.onNext(())
            }.disposed(by: bag)
        
        input.cancel.drive {  _ in
            backAction.onNext(())
        }.disposed(by: bag)

        return (canCreate:canContinue, textCount:textDescDriver, selectedSubscirbers:selectedSubscirbers, subscribers:subscribers_, textBlock:textBlock)
    }
}


