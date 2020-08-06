//
//  DomainFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import RedditAPI

class DomainFilter: StringFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard let link = thing as? Link else { return false }
    guard subredditValid(thing: link) else { return false }
    guard let domain = link.domain else { return false }
    return compare(source: domain)
  }
  
  override func name() -> String {
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    let containsString = contains ? " contains" : " is"
    return "\(subredditString)Link Domain\(containsString) \(query)"
  }
}
