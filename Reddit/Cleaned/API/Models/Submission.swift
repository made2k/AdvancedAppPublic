//
//  Submission.swift
//  Reddit
//
//  Created by made2k on 9/11/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct Submission {
  
  let link: URL?
  let text: String?
  
  let subreddit: String
  let title: String
  
  let sendReplies: Bool
  
  var kind: String {
    if link != nil {
      return "link"
    } else {
      return "self"
    }
  }
  
  init(subreddit: String, title: String, replies: Bool, link: URL) {
    self.subreddit = subreddit
    self.title = title
    self.sendReplies = replies
    self.link = link
    self.text = nil
  }
  
  init(subreddit: String, title: String, replies: Bool, text: String) {
    self.subreddit = subreddit
    self.title = title
    self.sendReplies = replies
    self.text = text
    self.link = nil
  }
  
}
