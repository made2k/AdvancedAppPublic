//
//  YouTubeLinkMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct YouTubeLinkMatcher {

  static func match(_ url: URL) -> URL? {
    guard let host = url.host, host.contains("youtube.com") || host.contains("youtu.be") else { return nil }
    return url
  }

}
