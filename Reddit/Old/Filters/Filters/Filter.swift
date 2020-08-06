//
//  Filter.swift
//  Reddit
//
//  Created by made2k on 5/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Foundation
import RealmSwift
import RedditAPI

protocol FilterProtocol {
  func filter(thing: Thing) -> Bool
  func name() -> String
}

class Filter: Object, FilterProtocol {
  
  @objc dynamic var subreddit: String? = nil
  
  func filter(thing: Thing) -> Bool {
    return false
  }
  
  func name() -> String {
    return ""
  }
  
  /**
   Checks if the subreddit applies to this filter.
   This is a fast failure for anything that would
   compare a thing in the wrong subreddit.
   
   For instance, if we have a filter of the word
   "cat" IN r/aww, if "cat" appears in r/catsstandingup
   the filter would not apply as this would return false.
   */
  func subredditValid(thing: Thing) -> Bool {
    if let comment = thing as? Comment {
      return subredditValid(comment: comment)
      
    } else if let link = thing as? Link {
      return subredditValid(link: link)
    }
    
    return false
  }
  
  func subredditValid(comment: Comment) -> Bool {
    if
      let commentSubreddit = comment.subreddit,
      let subreddit = subreddit,
      commentSubreddit ~== subreddit {
      return true
    }
    
    return comment.subreddit == nil || subreddit == nil
  }
  
  func subredditValid(link: Link) -> Bool {
    if
      let subreddit = subreddit,
      subreddit ~== link.subreddit {
      return true
    }
    return subreddit == nil
  }
  
}
