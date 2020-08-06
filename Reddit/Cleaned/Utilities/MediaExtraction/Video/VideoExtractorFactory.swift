//
//  VideoExtractorFactory.swift
//  Reddit
//
//  Created by made2k on 6/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RedditAPI

class VideoExtractorFactory: NSObject {
  
  static func extractor(for link: Link) -> VideoExtractable? {
    
    guard let url = link.url else { return nil }
    guard let domain = link.domain else { return nil }
    
    guard let host = SupportedVideoExtractionHosts.match(domain: domain) else {
      return nil
    }
    
    switch host {
    case .streamable: return StreamableExtractor(url: url)
    case .vimeo: return VimeoExtractor(url: url)
    case .youtube, .youtubeShort: return YoutubeExtractor(url: url)
    }
    
  }

}
