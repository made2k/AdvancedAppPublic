//
//  UserFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class UserFilter: StringFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard let author = (thing as? Link)?.author.lowercasedTrim ?? (thing as? Comment)?.author.lowercasedTrim else { return false }
    guard subredditValid(thing: thing) else { return false }
    
    return compare(source: author)
  }
  
  override func name() -> String {
    let containsString = contains ? " contains" : " is"
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    return "\(subredditString)Users name\(containsString) \(query)"
  }
}

class LinkUserFilter: UserFilter { }
class CommentUserFilter: UserFilter { }
