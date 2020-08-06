//
//  SubredditListingMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct SubredditListingMatcher {

  private static let host = "reddit.com"
  private static let prefix = "/r/"

  static func match(_ url: URL) -> String? {

    guard url.host?.contains(host) == true || url.absoluteString.hasPrefix(prefix) else { return nil }

    let pathComponents = url.sanitizedPathComponents
    guard pathComponents.first == "r" else { return nil }
    guard pathComponents.contains("submit") == false else { return nil }

    return pathComponents[safe: 1]
  }

}
