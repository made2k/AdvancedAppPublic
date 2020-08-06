//
//  ImageExtractorFactory.swift
//  Reddit
//
//  Created by made2k on 6/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation

final class ImageExtractorFactory: NSObject {

  static func extractor(for url: URL) -> ImageExtractable? {

    guard let match = SupportedImageExtractionHosts.match(url: url) else {
      return nil
    }

    switch match {

    case .imgur: return ImgurExtractor(url: url)
    case .reddit: return RedditExtractor(url: url)
    case .redditPreview: return RedditPreviewExtractor(url: url)
    case .redditVideo: return RedditVideoExtractor(url: url)
    case .gfycat: return GfycatExtractor(url: url)
    case .giphy: return GiphyExtractor(url: url)
    case .redgifs: return RedGifsExtractor(url: url)
    }

  }

}
