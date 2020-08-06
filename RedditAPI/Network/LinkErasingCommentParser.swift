//
//  LinkErasingCommentParser.swift
//  RedditAPI
//
//  Created by made2k on 4/24/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Logging

struct LinkErasingCommentParser: Decodable {

  let link: Link?

  init(from decoder: Decoder) throws {

    // Erase the comment
    if (try? Comment(from: decoder)) != nil {
      log.debug("comment was erased for link")
      self.link = nil

    } else {
      // If not comment, this should be a link
      self.link = try Link(from: decoder)
    }

  }

}
