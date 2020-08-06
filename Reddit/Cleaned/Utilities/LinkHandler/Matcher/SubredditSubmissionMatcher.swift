//
//  SubredditListingMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RedditAPI

typealias SubmissionMatch = (subredditName: String, type: SubmissionType, subject: String?)

struct SubredditSubmissionMatcher {
  
  //http://www.reddit.com/r/askreddit/submit?selftext=true&title=%5BSerious%5D

  static func match(_ url: URL) -> SubmissionMatch? {
    
    let pathComponents = url.sanitizedPathComponents
    
    // Needs to have r, subname, submit
    guard pathComponents.count >= 3 else { return nil }
    guard pathComponents[0].caseInsensitiveCompare("r") == .orderedSame else { return nil }
    guard pathComponents[2].caseInsensitiveCompare("submit") == .orderedSame else { return nil }
    guard url.host?.contains("reddit.com", caseSensitive: true) == true || url.host == nil else { return nil }
    
    let subreddit = pathComponents[1]
    let submitType: SubmissionType
    
    if let selfTextParameter = url.queryParameters?["selftext"], selfTextParameter ~== "true" {
      submitType = .selftext
      
    } else {
      submitType = .link
    }
    
    let subject = url.queryParameters?["title"]
    
    return (subreddit, submitType, subject)
  }

}
