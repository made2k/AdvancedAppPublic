//
//  FlairFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class FlairFilter: StringFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard let flair = (thing as? Link)?.flair?.text?.lowercasedTrim ?? (thing as? Comment)?.flair?.text?.lowercasedTrim else { return false }
    guard subredditValid(thing: thing) else { return false }
    
    return compare(source: flair)
  }
  
  override func name() -> String {
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    let containsString = contains ? " contains" : " is"
    return "\(subredditString)Link Flair\(containsString) \(query)"
  }
}

class LinkFlairFilter: FlairFilter { }
class CommentFlairFilter: FlairFilter {}

