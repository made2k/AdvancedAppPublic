//
//  RedditVideoMatcher.swift
//  Reddit
//
//  Created by made2k on 8/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct RedditVideoMatcher {
  
  static func match(_ url: URL) -> URL? {
    guard let host = url.host, host == "v.redd.it" else { return nil }
    
    guard url.pathExtension == "m3u8" || url.queryValue(for: "source") == "fallback" else { return nil }
    
    return url
  }
  
}
