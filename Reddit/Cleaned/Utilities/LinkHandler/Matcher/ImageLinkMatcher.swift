//
//  ImageLinkMatcher.swift
//  Reddit
//
//  Created by made2k on 6/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

struct ImageLinkMatcher {
  
  static func match(_ url: URL) -> URL? {
    return ImageExtractor.shared.supportsLink(url: url) ? url : nil
  }

}
