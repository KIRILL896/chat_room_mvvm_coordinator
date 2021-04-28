//
//  MyEventCellModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol MyEventCellModelType {
    var date:String {get}
    var description:String {get}
    var descriptionName:String {get}
}

struct MyEventCellModel:MyEventCellModelType, IdentifiableType, Hashable, Equatable {
    var description: String
    var descriptionName: String
    typealias Identity = String
    var date: String
    var identity: String { return description }

    static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.description == rhs.description
    }
}



struct Subscriber_: Codable, IdentifiableType, Hashable, Equatable{
    var identity: String
    
    typealias Identity = String
    
    let id: String
    let firstname, lastname, nickname: String?
    let photo: Photo?
    
    var selected:Bool
    
    init(model:Subscriber) {
        self.id = model.id
        self.identity = model.id
        self.firstname = model.firstname
        self.lastname = model.lastname
        self.nickname = model.nickname
        self.photo = model.photo
        self.selected = false
    }
    
    
}
