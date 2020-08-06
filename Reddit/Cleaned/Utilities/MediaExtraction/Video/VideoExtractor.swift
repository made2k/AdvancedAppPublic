//
//  VideoExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import PromiseKit
import RedditAPI

final class VideoExtractor: NSObject {
  
  // MARK: - Helpers
  
  static func providerType(link: Link) -> VideoProviderType {
    guard let domain = link.domain else { return .none }
    return providerType(domain: domain)
  }
  
  static func providerType(domain: String) -> VideoProviderType {
    
    guard let extractorType = SupportedVideoExtractionHosts.match(domain: domain) else  {
      return .none
    }
    
    switch extractorType {
      
    case .youtube, .youtubeShort:
      return .youtube
      
    case .streamable, .vimeo:
      return .generic
      
    }
    
  }
  
  // MARK: - Extraction
  
  static func extractVideoUrl(link: Link) -> Promise<URL> {
    
    guard let extractor = VideoExtractorFactory.extractor(for: link) else {
      
      // We don't have an extractor for this link, try to
      // grab any attached media and use that.
      if let media = link.media, media.isGif == false {
        return .value(media.hlsUrl)
      }
      
      return .error(MediaExtractionError.mediaNotSupported)
    }
    
    return extractor.extractVideo()
  }
  
}
