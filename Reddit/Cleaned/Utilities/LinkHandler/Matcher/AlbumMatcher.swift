//
//  AlbumMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct AlbumMatcher {
  
  private static let host = "imgur.com"
  private static let approvedParameters = Set<String>(["a", "gallery", "t"])
  
  static func matchAlbum(_ url: URL) -> URL? {
    
    guard url.host?.contains(host) == true else { return nil }
    
    let pathComponents = Set<String>(url.sanitizedPathComponents)
    let hasValidPath = pathComponents.intersection(approvedParameters).isNotEmpty
    
    return hasValidPath ? url : nil
    
  }

}
