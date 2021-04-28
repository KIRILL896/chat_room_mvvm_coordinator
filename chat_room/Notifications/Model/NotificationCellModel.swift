//
//  NotificationCellModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol NotificationCellModelType {
    var date:Int? {get}
    var name:String {get}
    var avatar:String {get}
    var nameDescription:String {get}
}

struct NotificationCellModel:NotificationCellModelType, IdentifiableType, Hashable, Equatable {
    var nameDescription: String
    typealias Identity = String
    var date: Int?
    var name: String
    var avatar: String
    var type:String?
    var inviteType:String?
    var identity: String { return name }

    static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.name == rhs.name
    }
    
    init(requestModel:NotificationWithEvent) {
        self.date = requestModel.timeAgo
        self.name = requestModel.name ?? ""
        let host = requestModel.photo?.host ?? ""
        let path = requestModel.photo?.path ?? ""
        let ext = requestModel.photo?.ext ?? ""
        self.avatar = "\(host)/\(path)_\(32).\(ext)"
        self.type = requestModel.type
        self.inviteType = requestModel.inviteType
        self.nameDescription = requestModel.eventName ?? ""
    }
    
}


