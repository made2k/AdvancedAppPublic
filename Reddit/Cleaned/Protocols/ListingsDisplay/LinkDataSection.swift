//
//  LinkDataSection.swift
//  Reddit
//
//  Created by made2k on 7/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Differentiator

struct LinkDataSection {
  var items: [Item]
}

extension LinkDataSection: AnimatableSectionModelType {
  typealias Identity = String
  typealias Item = LinkModel

  var identity: String {
    return "link"
  }

  init(original: LinkDataSection, items: [LinkModel]) {
    self = original
    self.items = items
  }

}

extension LinkModel: IdentifiableType {
  typealias Identity = String
  var identity: String {
    return "\(link.id)\(voteDirection.rawValue)"
  }
}
