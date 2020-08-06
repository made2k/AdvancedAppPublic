//
//  LinkEditModel.swift
//  Reddit
//
//  Created by made2k on 8/6/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import UIKit

class LinkEditModel: ViewModel {

  private let editingModel: LinkModel

  let title = R.string.replyCreate.titleEditLink()

  init(editingModel: LinkModel) {
    self.editingModel = editingModel
  }

  func save(_ text: String) -> Promise<Link> {

    firstly {
      api.session.editUserText(thing: editingModel.link, newText: text)

    }.map {
      guard let link = $0 as? Link else {
        log.warn("could not get link after editing link")
        throw APIError.unknown
      }

      return link
    }

  }

}
