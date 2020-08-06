//
//  RedditWikiMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct RedditWikiMatcher {

  private static let host = "reddit.com"

  static func match(_ url: URL) -> URL? {
    return matchSubredditWiki(url) ?? matchTopLevelWiki(url)
  }

  private static func matchSubredditWiki(_ url: URL) -> URL? {
    let pathComponents = url.sanitizedPathComponents

    guard url.host?.contains(host) == true || pathComponents.first == "r" else { return nil }

    guard pathComponents.contains("wiki") || pathComponents.contains("rules") else { return nil }

    if url.absoluteString.hasPrefix("/r/") {
      let resolvedUrlString = "https://www.reddit.com\(url.absoluteString)"
      return URL(string: resolvedUrlString)
    }

    return url
  }

  private static func matchTopLevelWiki(_ url: URL) -> URL? {
    let pathComponents = url.sanitizedPathComponents

    guard url.host?.contains(host) == true || pathComponents.first == "wiki" else { return nil }
    guard pathComponents.first == "wiki" else { return nil }

    if url.absoluteString.hasPrefix("/wiki") {
      let resolvedUrlString = "https://www.reddit.com\(url.absoluteString)"
      return URL(string: resolvedUrlString)
    }

    return url
  }

}
