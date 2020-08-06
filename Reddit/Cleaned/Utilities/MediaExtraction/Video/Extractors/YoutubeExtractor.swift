//
//  YoutubeExtractor.swift
//  Reddit
//
//  Created by made2k on 6/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import XCDYouTubeKit

class YoutubeExtractor: NSObject, VideoExtractable {
  
  private let url: URL
  private var retain: YoutubeExtractor?
  
  required init(url: URL) {
    self.url = url
  }
  
  func extractVideo() -> Promise<URL> {
    
    guard let videoId = parseVideoId() else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    let timeStamp = parseTimeStamp()

    retain = self
    
    return Promise { seal in
      
      let client = XCDYouTubeClient.default()
      
      client.getVideoWithIdentifier(videoId) { [unowned self] video, error in

        defer { self.retain = nil }

        guard let video = video else {
          return seal.reject(error ?? MediaExtractionError.mediaNotSupported)
        }
        
        guard var videoQuality = self.getQuality(for: video) else {
          return seal.reject(MediaExtractionError.mediaNotSupported)
        }

        if let timeStamp = timeStamp {
          let parameters = ["t": "\(timeStamp)"]
          videoQuality.appendQueryParameters(parameters)
        }

        seal.fulfill(videoQuality)
      }
      
    }
    
  }
  
  private func parseVideoId() -> String? {

    if let videoId = url.queryParameters?["v"] {
      return videoId
    }
    
    if let videoId = url.absoluteString.substring(after: "v=", before: "&") {
      return videoId
    }
    
    return url.pathComponents.first(where: { $0.count == 11 })

  }

  private func parseTimeStamp() -> TimeInterval? {

    guard let queryValue = url.queryParameters?["t"] else {
      return nil
    }

    return TimeInterval(string: queryValue)
  }
  
  private func getQuality(for video: XCDYouTubeVideo) -> URL? {
    
    let quality = Reachability.shared.isReachableOnWiFi ?
      XCDYouTubeVideo.highQuality :
      XCDYouTubeVideo.mediumQuality
    
    return video.streamUrl(for: quality)
  }

}

private extension XCDYouTubeVideo {
  
  static var highQuality: [XCDYouTubeVideoQuality] = [
    .HD720,
    .medium360,
    .small240]
  static var mediumQuality: [XCDYouTubeVideoQuality] = [
    .medium360,
    .small240,
    .HD720]
  
  func streamUrl(for qualityProfile: [XCDYouTubeVideoQuality]) -> URL? {
    
    for quality in qualityProfile {
      
      if let url = streamURLs[quality.rawValue] {
        return url
      }
    }
    
    return nil
  }
  
}
