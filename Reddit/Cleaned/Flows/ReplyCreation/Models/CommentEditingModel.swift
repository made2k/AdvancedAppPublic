//
//  CommentEditingModel.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI

class CommentEditingModel: ViewModel {

  private let editingModel: CommentModel
  
  let title = R.string.replyCreate.titleEditComment()
  
  init(editingModel: CommentModel) {
    self.editingModel = editingModel
  }
  
  func save(_ text: String) -> Promise<Comment> {
    
    return firstly {
      api.session.editUserText(thing: editingModel.comment, newText: text)

    }.map {

      guard let comment = $0 as? Comment else {
        log.warn("could not get comment after editing comment")
        throw APIError.unknown
      }

      return comment
    }

  }
  
}
