//
//  GfycatExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import Logging
import PromiseKit
import SwiftyJSON

final class GfycatExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {

    if url.pathExtension.lowercased() == "mp4" {
      return .value(ImageExtractionResult(type: .video, url: url))
    }

    if url.pathExtension.lowercased() == "webm" {
      let mp4Url = url.deletingPathExtension().appendingPathExtension("mp4")
      return .value(ImageExtractionResult(type: .video, url: mp4Url))
    }

    guard
      let identifier = parseIdentifier(),
      let baseUrl = URL(string: cleanedUrlString()),
      let apiUrl = URL(string: "https://api.gfycat.com/v1test/gfycats/\(identifier)") else {
        return .error(MediaExtractionError.mediaNotSupported)
    }

    return firstly {
      requestAPI(apiUrl: apiUrl)

    }.recover { error -> Promise<ImageExtractionResult> in
      log.error("failed to fetch media from gfycat api", error: error)
      return self.requestScrape(baseUrl: baseUrl)
    }

  }

  // MARK: - Helpers

  private func cleanedUrlString() -> String {
    return "https://gfycat.com/" + url.absoluteString.substringOrSelf(after: "gfycat.com/")
  }

  private func parseIdentifier() -> String? {

    // remove any qualifiers to gfycat
    let cleanedString = cleanedUrlString()

    let components = cleanedString.components(separatedBy: "/")
    return components.last?.substringOrSelf(before: ".").substringOrSelf(before: "-")
  }

  // MARK: - Requests

  // MARK: API Data

  private func requestAPI(apiUrl: URL) -> Promise<ImageExtractionResult> {

    var request = URLRequest(url: apiUrl)
    request.setUserAgentForReddit()
    request.httpMethod = HTTPMethod.get.rawValue

    return AF.request(request)
      .validate(statusCode: 200..<300)
      .responseJsonObject(queue: .global())
      .map { try self.parseApiData($0) }

  }

  private func parseApiData(_ json: JSON) throws -> ImageExtractionResult {

    let gfyItem = json["gfyItem"]

    if let url = gfyItem["mobileUrl"].url, url.pathExtension == "mp4" {
      return ImageExtractionResult(type: .video, url: url)
    }

    if let url = gfyItem["mp4Url"].url {
      return ImageExtractionResult(type: .video, url: url)
    }

    if let url = gfyItem["gifUrl"].url {
      return ImageExtractionResult(type: .gif, url: url)
    }

    throw MediaExtractionError.mediaUrlNotFound
  }

  // MARK: Scrape Data

  private func requestScrape(baseUrl: URL) -> Promise<ImageExtractionResult> {

    var request = URLRequest(url: baseUrl)
    request.setUserAgentForReddit()
    request.httpMethod = HTTPMethod.get.rawValue

    return AF.request(request)
      .responseString(queue: .global())
      .map { $0.0 }
      .map { ($0 as NSString).replacingHTMLEntities() as String }
      .map { try self.parseScrapeData($0) }

  }

  private func parseScrapeData(_ response: String) throws -> ImageExtractionResult {

    let mobilePattern = "https://[a-zA-Z]+\\.gfycat\\.com/[a-zA-Z]+(-mobile).mp4"
    let fullPattern = "https://[a-zA-Z]+\\.gfycat\\.com/[a-zA-Z]+(-mobile)?.mp4"

    guard let url = parseRegex(response, pattern: mobilePattern, group: 0) ??
      parseRegex(response, pattern: fullPattern, group: 0) else {

        throw MediaExtractionError.mediaUrlNotFound
    }

    return ImageExtractionResult(type: .video, url: url)

  }

  private func parseRegex(_ response: String, pattern: String, group: Int) -> URL? {

    do {

      guard let match = try response.match(regex: pattern, options: .caseInsensitive).first,
        match.numberOfRanges >= group else {
          return nil
      }

      let result = response.substring(nsRange: match.range(at: group))

      return URL(string: result)?.safeScheme()

    } catch {
      log.error("unable to create regex for gfycat", error: error)
      return nil
    }

  }
  
}
