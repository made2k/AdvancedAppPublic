//
//  RedGifsExtractor.swift
//  Reddit
//
//  Created by made2k on 6/2/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class RedGifsExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {

    if url.pathExtension.lowercased() == "mp4" {
      return .value(ImageExtractionResult(type: .video, url: url))
    }

    var request = URLRequest(url: url)
    request.setUserAgentForReddit()
    request.httpMethod = HTTPMethod.get.rawValue

    return AF.request(request)
      .validate(statusCode: 200..<300)
      .responseString(queue: .global())
      .map(\.0)
      .map { try self.extractVideo(from: $0) }

  }

  // MARK: - URL Expansion Requests

  private func extractVideo(from response: String) throws -> ImageExtractionResult {

    let pattern = "(<source src=\")([^\"]+)(\"\\s*type=\"video\\/mp4\"\\/>)"

    let results: [String] = try response.match(regex: pattern, options: .caseInsensitive)
      .filter {
        $0.numberOfRanges >= 3
      }
      .map {
        response.substring(nsRange: $0.range(at: 2))
      }

    // Good spot for limit data option here
    let optionalResult: String? = results.first { $0.contains("mobile") } ?? results.first

    guard let result = optionalResult else {
      throw MediaExtractionError.mediaUrlNotFound
    }

    guard let url = URL(string: result) else {
      throw MediaExtractionError.mediaUrlNotFound
    }

    return ImageExtractionResult(type: .video, url: url)
  }

}

