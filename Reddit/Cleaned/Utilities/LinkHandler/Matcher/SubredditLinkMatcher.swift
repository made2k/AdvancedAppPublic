//
//  SubredditLinkMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

typealias SubredditLinkMatch = (subreddit: String?, linkName: String, postTitle: String?, focusId: String?, context: String?)

struct SubredditLinkMatcher {
  
  // Messages using the short host will have one parameter
  // and that is the name of the link
  static let shortHost = "redd.it"
  static let host = "reddit.com"

  static func match(_ url: URL, focusingId: String? = nil) -> SubredditLinkMatch?  {
    
    if let shortMatch = matchShortUrl(url) {
      return (nil, shortMatch, nil, focusingId, nil)
    }
    
    return matchLongUrl(url, providedFocus: focusingId)
  }
  
  private static func matchShortUrl(_ url: URL) -> String? {
    
    guard url.host == shortHost else { return nil }
    guard let name = url.sanitizedPathComponents.first else { return nil }
    guard url.sanitizedPathComponents.count == 1 else { return nil }
    
    return name
    
  }
  
  private static func matchLongUrl(_ url: URL, providedFocus: String?) -> SubredditLinkMatch? {
    
    guard url.host?.contains("reddit.com") == true || url.absoluteString.hasPrefix("/r/") else { return nil }
    
    /*
     The reddit pathing should be structured as follows:
     SCHEME://www.reddit.com/r/SUBREDDIT/comments/LINK_NAME/TITLE/FOCUS_NAME
     */
    
    let pathComponents = url.sanitizedPathComponentsAllowingDots
    
    guard let subredditName = pathComponents[safe: 1] else { return nil }
    
    guard let commentsIndex = pathComponents.firstIndex(of: "comments") else { return nil }

    let linkIndex = commentsIndex + 1
    let titleIndex = linkIndex + 1
    let focusIndex = titleIndex + 1
    
    guard pathComponents.count > linkIndex else { return nil }
    
    let linkName = pathComponents[linkIndex]
    let titleName = pathComponents[safe: titleIndex]
    let focusName = providedFocus ?? pathComponents[safe: focusIndex]
    let context = url.queryParameters?["context"]
    
    return (subredditName, linkName, titleName, focusName, context)
  }
  
}
