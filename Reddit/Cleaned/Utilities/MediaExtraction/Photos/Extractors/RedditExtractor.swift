//
//  RedditExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import PromiseKit

final class RedditExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {
    return .value(ImageExtractionResult(type: .image, url: url))
  }

}
