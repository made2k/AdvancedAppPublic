//
//  RedditVideoExtractor.swift
//  Reddit
//
//  Created by made2k on 8/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit

/**
 Note: If this extractor is being used, it should mean that the video is comfortable
 being downloaded before displayed. Thus, it should only be used when `.isGif` is true
 on a `RedditMedia` object
 */
final class RedditVideoExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {
    return .value(ImageExtractionResult(type: .video, url: url))
  }

}
