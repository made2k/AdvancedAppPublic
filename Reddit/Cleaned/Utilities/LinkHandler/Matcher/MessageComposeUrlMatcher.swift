//
//  MessageComposeUrlMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

typealias MessageComposeMatch = (recipient: String?, subject: String?, message: String?)

struct MessageComposeUrlMatcher {
  
  private static let toQueryParameter = "to"
  private static let subjectQueryParameter = "subject"
  private static let messageQueryParameter = "message"
  
  private static let host = "reddit.com"
  
  static func match(_ url: URL) -> MessageComposeMatch? {
      
    guard url.host?.contains(host) == true || url.host == nil else { return nil }
    guard url.path.contains("message/compose") else { return nil }
    
    let recipient = url.queryParameters?[toQueryParameter]
    let subject = url.queryParameters?[subjectQueryParameter]
    let message = url.queryParameters?[messageQueryParameter]
    
    return (recipient, subject, message)
    
  }
  
}
