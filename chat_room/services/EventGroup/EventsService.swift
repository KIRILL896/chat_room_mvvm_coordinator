//
//  EventsService.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import RxSwift
import RxCocoa
import Alamofire
class EventsService:NetworkService {
    
    static let shared = EventsService()
    private let defaultsService = DefaultsService()
    private let keychainService = KeychainService()
    
    
    
    func createEvent(eventName: String, eventDescription: String, speakers: [String], date: String, timezone: String) -> Observable<Bool> {
        
        let url = host + "event/create"
        
        let token = KeychainService().accessToken
        let headers = ["Auth": "\(token)"]
        
        var params: [String:AnyObject] = [:]
        params["name"] = eventName as AnyObject
        params["description"] = eventDescription as AnyObject
        params["speakers"] = speakers as AnyObject
        params["date"] = date as AnyObject
        params["timezone"] = timezone as AnyObject
        
        
        return Observable<Bool>.create { [weak self] observer in
            guard let self = self else { fatalError("error") }

            self.sendRequest(requestType: .post, url: url, parameters: params, paramsEncoding: JSONEncoding.default, headers: headers) { (jsonData, isConnect, error) in
                if !isConnect {
                    print("No internet connection")
                    observer.onNext(false)
                    observer.onCompleted()
                }
                if let string = jsonData?["message"].string {
                    if string != "" {
                        print("string \(string)")
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }
                if let c = jsonData?.dictionaryObject {
                    print("dictionaryObject \(c)")
                    observer.onNext(true)
                    observer.onCompleted()
                    return
                }
                
                if let error = error {
                    print("eror \(error)")
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    

    func createEvent(map:CreateEventRequest)  -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] observer in
            guard let self = self else { fatalError("error") }
            let routing:UserNetworkRouter = .createEvent(map.toJson())
            self.sendRequest(routing, responseType: EventResponse.self, completion: { (response, error) in
                if let event = response {
                    print("got create event \(event)")
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    print("ERROR \(error)")
                    observer.onNext(false)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    

    func get_all_events(type: String) -> Observable<EventList>{
        return Observable<EventList>.create { [weak self] observer in
            guard let self = self else { fatalError("error") }
            let routing: UserNetworkRouter = .getEvents(type)
            self.sendRequest(routing, responseType: EventsListResponse.self, completion: { (response, error) in
                if let list = response?.eventList {
                    observer.onNext(list)
                    observer.onCompleted()
                } else {
                    observer.onError(error!)
                }
            })
            return Disposables.create()
        }
    }
}
