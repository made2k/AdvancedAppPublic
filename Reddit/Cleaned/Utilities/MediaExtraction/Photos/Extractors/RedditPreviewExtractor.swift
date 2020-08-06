//
//  RedditPreviewExtractor.swift
//  Reddit
//
//  Created by made2k on 7/9/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit

final class RedditPreviewExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {
    if url.queryValue(for: "format") == "mp4" {
      return .value(ImageExtractionResult(type: .video, url: url))
    }
    
    return .value(ImageExtractionResult(type: .image, url: url))
  }

}
