//
//  TopSpeakersSectionModel.swift
//  Liveroom
//
//  Created by отмеченные on 04.04.2021.
//

import RxSwift
import RxCocoa
import RxDataSources


struct TopSpeakersSectionModel {
  var items: [Item]
  var title: String
  var id: String
    
    static func empty(title:String) -> TopSpeakersSectionModel {
      return TopSpeakersSectionModel(items: [], title: title, id: UUID().uuidString)
  }
}

extension TopSpeakersSectionModel: SectionModelType {
  typealias Item = Subscriber_
  init(original: TopSpeakersSectionModel, items: [Subscriber_]) {
    self.title = original.title
    self.id = original.id
    self.items = items
  }
}

extension TopSpeakersSectionModel: AnimatableSectionModelType {
  typealias Identity = [Item]
  var identity: [Item] {
    return items
  }
}
