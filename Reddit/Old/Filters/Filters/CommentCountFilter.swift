//
//  CommentCountFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class CommentCountPostFilter: NumberFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard let link = thing as? Link else { return false }
    guard subredditValid(thing: thing) else { return false }
    return compare(target: link.commentCount)
  }
  
  override func name() -> String {
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    let greaterString = greaterThan ? " greater" : " less"
    return "\(subredditString)Number of comments\(greaterString) than \(number)"
  }
}
