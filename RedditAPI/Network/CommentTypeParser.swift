//
//  CommentTypeParser.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct CommentTypeParser: Decodable {

  let commentType: CommentType

  init(from decoder: Decoder) throws {
    
    if let comment = try? Comment(from: decoder) {
      commentType = .comment(value: comment)

    } else {
      let more = try More(from: decoder)
      commentType = .more(value: more)
    }

  }

}
