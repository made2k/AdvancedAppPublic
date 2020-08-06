//
//  Sequence+Additions.swift
//  RedditAPI
//
//  Created by made2k on 3/21/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Sequence where Iterator.Element == CommentType {

  func filterEmpty() -> [CommentType] {

    filter { (commentType: CommentType) in
      switch commentType {
      case .comment:
        return true

      case .more(let value):
        return value.childrenIds.isEmpty == false
      }
    }

  }

}
