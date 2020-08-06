//
//  VimeoExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

class VimeoExtractor: NSObject, VideoExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractVideo() -> Promise<URL> {

    guard
      let videoId = parseVideoId(),
      let fetchUrl = URL(string: "https://player.vimeo.com/video/\(videoId)/config")
    else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    return AF.request(fetchUrl)
      .validate(statusCode: 200..<300)
      .responseJsonObject(queue: .global())
      .map { try self.parseJson($0) }

  }

  private func parseVideoId() -> String? {

    return url.pathComponents
      .filter { $0 != "/" }
      .filter { $0.isNumeric }
      .last

  }

  private func parseJson(_ json: JSON) throws -> URL {

    if let hls = parseHls(json) {
      return hls
    }

    if let stream = parseStream(json) {
      return stream
    }

    throw MediaExtractionError.mediaUrlNotFound

  }

  private func parseHls(_ json: JSON) -> URL? {

    let hls = json["request"]["files"]["hls"]

    guard hls["separate_av"].bool == false else { return nil }

    if let fastly = hls["cdns"]["fastly_skyfire"]["url"].url {
      return fastly
    }

    if let akfire = hls["cdns"]["akfire_interconnect_quic"]["url"].url {
      return akfire
    }

    return nil

  }

  private func parseStream(_ json: JSON) -> URL? {

    guard let progressiveArray = json["request"]["files"]["progressive"].array else {
      return nil
    }

    let qualityIdentifier = Reachability.shared.isReachableOnWiFi ? "1080p" : "540p"

    let validEntries = progressiveArray
      .filter { $0["mime"] == "video/mp4" }
      .filter { $0["quality"].string == qualityIdentifier }

    guard let urlString = validEntries.first?["url"].string else { return nil }
    return URL(string: urlString)

  }

}
