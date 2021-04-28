//
//  MyEventSectionModel.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//




import RxSwift
import RxCocoa
import RxDataSources


struct MyEventSectionModel {
  var items: [Item]
  var title: String
  var id: String
    
    static func empty(title:String) -> MyEventSectionModel {
      return MyEventSectionModel(items: [], title: title, id: UUID().uuidString)
  }
}

extension MyEventSectionModel: SectionModelType {
  typealias Item = Event

  init(original: MyEventSectionModel, items: [Event]) {
    self.title = original.title
    self.id = original.id
    self.items = items
  }
}

extension MyEventSectionModel: AnimatableSectionModelType {
  typealias Identity = [Item]
  var identity: [Item] {
    return items
  }
}

