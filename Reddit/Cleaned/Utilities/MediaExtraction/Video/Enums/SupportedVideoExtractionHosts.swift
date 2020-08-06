//
//  SupportedVideoExtractionHosts.swift
//  Reddit
//
//  Created by made2k on 6/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

enum SupportedVideoExtractionHosts: String, CaseIterable {
  case streamable = "streamable.com"
  case vimeo = "vimeo.com"
  case youtube = "youtube.com"
  case youtubeShort = "youtu.be"
  
  static func match(domain: String) -> SupportedVideoExtractionHosts? {
    
    for host in SupportedVideoExtractionHosts.allCases {
      if host.match(urlString: domain) { return host }
    }
    
    return nil
  }
  
  func match(url: URL) -> Bool {
    return match(urlString: url.absoluteString)
  }
  
  func match(urlString: String) -> Bool {
    return urlString.contains(rawValue)
  }
  
}
