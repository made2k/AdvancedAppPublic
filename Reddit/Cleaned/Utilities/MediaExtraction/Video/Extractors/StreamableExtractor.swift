//
//  StreamableExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import Logging
import PromiseKit

class StreamableExtractor: NSObject, VideoExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractVideo() -> Promise<URL> {

    AF.request(url)
      .validate(statusCode: 200..<300)
      .responseString(queue: .global())
      .map { $0.0 }
      .map { try self.parseResponse($0) }

  }

  private func parseResponse(_ string: String) throws -> URL {

    let cleanedString = (string as NSString).replacingHTMLEntities() as String

    do {

      let regex = try NSRegularExpression(pattern: "(property=\"og:video?:?.+?\" content=\")(.+\\.mp4.+?)(\">)")

      guard
        let match = regex.firstMatch(in: cleanedString, options: [], range: cleanedString.nsRange),
        match.numberOfRanges == 4 else {

        throw MediaExtractionError.mediaUrlNotFound
      }

      let urlString = cleanedString.substring(nsRange: match.range(at: 2))

      guard let url = URL(string: urlString) else {
        throw MediaExtractionError.mediaUrlNotFound
      }

      return url

    } catch let error {
      log.error("Failed to parse streamable response", error: error)
      throw MediaExtractionError.unknown
    }

  }

}
