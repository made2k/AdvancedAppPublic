//
//  CommentModelTypeFactory.swift
//  Reddit
//
//  Created by made2k on 6/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

struct CommentModelTypeFactory {

  static func modelType(for item: CommentType, parent: CommentModel?) -> CommentModelType {

    switch item {
    case .comment(let value):
      return CommentModel(value, parent: parent)

    case .more(let value):
      return MoreModel(more: value, parent: parent)
    }

  }

}
