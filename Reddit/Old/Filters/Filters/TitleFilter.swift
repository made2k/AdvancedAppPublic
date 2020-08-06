//
//  TitleFilter.swift
//  Reddit
//
//  Created by made2k on 5/3/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import RedditAPI

class TitleFilter: StringFilter {
  
  override func filter(thing: Thing) -> Bool {
    guard subredditValid(thing: thing) else { return false }
    
    if let link = thing as? Link {
      return compare(link: link)
    } else if let comment = thing as? Comment {
      return compare(comment: comment)
    }
    
    return false
  }
  
  private func compare(comment: Comment) -> Bool {
    return compare(source: comment.body)
  }
  
  private func compare(link: Link) -> Bool {
    return compare(source: link.title)
  }
  
  override func name() -> String {
    let containsString = contains ? " contains" : " is"
    let subredditString = subreddit != nil ? "\(subreddit!) " : ""
    return "\(subredditString)Title\(containsString) \(query)"
  }
}

class LinkTitleFilter: TitleFilter { }
class CommentTitleFilter: TitleFilter { }
