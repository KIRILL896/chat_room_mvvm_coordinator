//
//  NotificationViewModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import RxSwift
import RxCocoa

protocol NotificationViewModelPresentable {
    typealias input = (
        clickAction:Driver<NotificationCellModel>, ()
    )
    typealias output = (
        notifications: Driver<[NotificationSectionModel]>, ()
    )
    typealias ViewModelBuilder = (NotificationViewModelPresentable.input) -> NotificationViewModelPresentable
    var input:NotificationViewModelPresentable.input {get}
    var output:NotificationViewModelPresentable.output {get}
}


class NotificationViewModel:NotificationViewModelPresentable {
    var input: NotificationViewModelPresentable.input
    
    var output:  NotificationViewModelPresentable.output

    private let notificationService: NotificationAppService
    
    private let disposeBag = DisposeBag()
    
    let notifications:BehaviorRelay<[NotificationWithEvent]> = BehaviorRelay<[NotificationWithEvent]>(value: [])
    
    init(input:NotificationViewModelPresentable.input, notificationService: NotificationAppService) {
        self.input = input
        self.notificationService = notificationService
        self.output = NotificationViewModel.output_(input: self.input, service: self.notificationService, notifications:notifications)
        self.process()
    }
}

extension NotificationViewModel {
    
    func process() {
        self
            .notificationService
            .get_notifications_list()
            .map { [weak self] data in
                print("got data \(data)")
                self?.notifications.accept(data)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
     static func output_(input:NotificationViewModelPresentable.input, service: NotificationAppService, notifications:BehaviorRelay<[NotificationWithEvent]>) -> NotificationViewModelPresentable.output{
        let notifications_ =
            notifications
            .asObservable()
            .map ({ noti -> [NotificationSectionModel] in
                let object = noti.map { val in return NotificationCellModel(requestModel: val)}
                return [NotificationSectionModel(original: NotificationSectionModel.empty(), items: object)]
            }).asDriver(onErrorJustReturn:[])
        
    
        return (notifications:notifications_, ())
    }
}



