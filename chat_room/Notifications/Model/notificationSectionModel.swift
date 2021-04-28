//
//  notificationSectionModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import RxSwift
import RxCocoa
import RxDataSources


struct NotificationSectionModel {
  var items: [Item]
  var title: String
  var id: String
    
  static func empty() -> NotificationSectionModel {
      return NotificationSectionModel(items: [], title: "", id: UUID().uuidString)
  }
}

extension NotificationSectionModel: SectionModelType {
  typealias Item = NotificationCellModel

  init(original: NotificationSectionModel, items: [NotificationCellModel]) {
    self.title = original.title
    self.id = original.id
    self.items = items
  }
}

extension NotificationSectionModel: AnimatableSectionModelType {
  typealias Identity = [Item]
  var identity: [Item] {
    return items
  }
}


