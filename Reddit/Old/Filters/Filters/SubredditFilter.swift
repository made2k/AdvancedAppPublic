//
//  SubredditFilter.swift
//  Reddit
//
//  Created by made2k on 5/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class SubredditFilter: StringFilter {
  
  convenience init(_ subreddit: String, contains: Bool) {
    self.init(subreddit, contains: contains, subreddit: nil)
  }
  
  override func filter(thing: Thing) -> Bool {
    guard let thing = thing as? Link else { return false }
    return compare(source: thing.subreddit)
  }
  
  override func name() -> String {
    let containsString = contains ? "contains" : "is"
    return "Subreddit name \(containsString) \(query)"
  }
}
