//
//  GiphyExtractor.swift
//  Reddit
//
//  Created by made2k on 3/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import PromiseKit

final class GiphyExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {

    if url.pathExtension.lowercased() == "mp4" {
      return .value(ImageExtractionResult(type: .video, url: url))
    }

    if url.host?.contains("gph.is") == true {
      return requestExpandedUrl()
    }

    guard
      let identifier = parseIdentifier(),
      let mediaUrl = URL(string: "https://media.giphy.com/media/\(identifier)/giphy.mp4") else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    return .value(ImageExtractionResult(type: .video, url: mediaUrl))

  }

  // MARK: - Helpers

  private func parseIdentifier() -> String? {

    let urlString = url.absoluteString

    guard let startIndex = urlString.lastRange(of: "media/")?.upperBound ??
      urlString.lastRange(of: "-")?.upperBound ??
      urlString.lastRange(of: "gifs/")?.upperBound else {
        return nil
    }

    let truncatedString = String(urlString[startIndex...])
    return truncatedString.substringOrSelf(before: "/")

  }

  // MARK: - URL Expansion Requests

  private func requestExpandedUrl() -> Promise<ImageExtractionResult> {

    var request = URLRequest(url: url)
    request.setUserAgentForReddit()

    return AF.request(request)
      .responseString()
      .map { $0.0 }
      .map { try self.parseVideo(from: $0) }
      .map { ImageExtractionResult(type: .video, url: $0) }

  }

  private func parseVideo(from response: String) throws -> URL {

    let pattern = "(\"og:video\"\\s+content=\")(https?://[a-zA-Z]+\\.giphy\\.com/[a-zA-Z0-9/]+.mp4)"

    guard
      let match = try response.match(regex: pattern, options: .caseInsensitive).first,
      match.numberOfRanges >= 3 else {
        throw MediaExtractionError.mediaUrlNotFound
    }

    let result = response.substring(nsRange: match.range(at: 2))

    guard let url = URL(string: result) else {
      throw MediaExtractionError.mediaUrlNotFound
    }

    return url

  }
  
}
