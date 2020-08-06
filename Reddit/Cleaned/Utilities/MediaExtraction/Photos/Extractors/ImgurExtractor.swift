//
//  ImgurExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import DTCoreText
import Foundation
import Logging
import PromiseKit

final class ImgurExtractor: NSObject, ImageExtractable {

  private let url: URL

  required init(url: URL) {
    self.url = url
  }

  func extractImage() -> Promise<ImageExtractionResult> {

    guard let host = url.host,
      url.absoluteString.contains(".com/a/", caseSensitive: false) == false else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    if host.contains("i.imgur.com", caseSensitive: false) {

      let pathExtension = url.pathExtension.lowercased()

      if pathExtension == "png" || pathExtension == "jpg" || pathExtension == "jpeg" {
        return .value(ImageExtractionResult(type: .image, url: url))
      }

      if pathExtension == "mp4" || pathExtension == "gifv" {
        let cleanedUrl = url.deletingPathExtension().appendingPathExtension("mp4")
        return .value(ImageExtractionResult(type: .video, url: cleanedUrl))
      }

    }

    guard let cleanedUrl = cleanUrl(url) else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    var request = URLRequest(url: cleanedUrl)
    request.setUserAgentForReddit()
    request.httpMethod = HTTPMethod.get.rawValue

    return AF.request(request)
      .validate(statusCode: 200..<300)
      .responseString(queue: .global())
      .map { $0.0 }
      .map { ($0 as NSString).replacingHTMLEntities() as String }
      .map { try self.extractResult(from: $0) }

  }

  // MARK: - Helpers

  private func cleanUrl(_ url: URL) -> URL? {

    // We want to grab the media from imgurs html.
    // We cannot trust extensions as a .jpg could be a gif,
    // a .gif, could be an image.
    let cleanedString = url.absoluteString
      .replacingOccurrences(of: ".gifv", with: "")
      .replacingOccurrences(of: ".gif", with: "")
      .replacingOccurrences(of: ".jpg", with: "")
      .replacingOccurrences(of: ".jpeg", with: "")
      .replacingOccurrences(of: ".png", with: "")
      .replacingOccurrences(of: ".mp4", with: "")
      .replacingOccurrences(of: "/i.", with: "/")

    return URL(string: cleanedString)
  }

  // MARK: - Result Extraction

  private func extractResult(from string: String) throws -> ImageExtractionResult {

    if let url = extractVideo(from: string) {
      return ImageExtractionResult(type: .video, url: url)
    }

    if let url = extractImage(from: string) {
      return ImageExtractionResult(type: .image, url: url)
    }

    throw MediaExtractionError.mediaUrlNotFound
  }

  // MARK: Video

  private func extractVideo(from string: String) -> URL? {
    return extractVideoContent(from: string) ??
      extractVideoSource(from: string) ??
      extractVideoMeta(from: string)
  }
  
  private func extractVideoSource(from string: String) -> URL? {

    do {

      let regex = try NSRegularExpression(pattern: "(<source src=\")(.+)(\" type=\"video\\/mp4)")

      guard
        let match  = regex.firstMatch(in: string, options: [], range: string.nsRange),
        match.numberOfRanges == 4 else {

          return nil
      }

      let urlString = string.substring(nsRange: match.range(at: 2))

      return URL(string: urlString)?.safeScheme()

    } catch {
      log.error("failed to extract video from imgur", error: error)
      return nil
    }

  }
  
  private func extractVideoMeta(from string: String) -> URL? {

    do {

      let regex = try NSRegularExpression(pattern: "(\"og:video\"\\s+)(.+\\.mp4)(\"\\s+/>)")

      guard let match = regex.firstMatch(in: string, options: [], range: string.nsRange) else {
          return nil
      }

      let result = string.substring(nsRange: match.range)
      guard let parsedResult = result.substring(after: "content=\"", before: "\" ") else {
        return nil
      }

      return URL(string: parsedResult)?.safeScheme()

    } catch {
      log.error("unable to parse imgur meta", error: error)
      return nil
    }

  }
  
  private func extractVideoContent(from string: String) -> URL? {

    do {

      let regex = try NSRegularExpression(pattern: "(content=\")(https?://i.imgur.com/[a-zA-Z0-9]+\\.mp4)")

      guard let match = regex.firstMatch(in: string, options: [], range: string.nsRange),
        match.numberOfRanges == 3 else {
          return nil
      }

      let urlString = string.substring(nsRange: match.range(at: 2))

      return URL(string: urlString)?.safeScheme()

    } catch let error {
      log.error("unable to extract video content from imgur", error: error)
      return nil
    }

  }

  // MARK: Image
  
  private func extractImage(from string: String) -> URL? {

    let pattern1 = "(<link\\s+rel=\"image_src\"\\s+href=\")(.+i.imgur.com/[a-zA-Z0-9]+.(jpg|jpeg|png))"
    let pattern2 = "(https?://i.imgur.com/[a-zA-Z0-9]+.(jpg|jpeg|png))"

    return extractImageUsingRegex(pattern: pattern1, string: string, range: 2) ??
      extractImageUsingRegex(pattern: pattern2, string: string, range: 1)
  }
  
  private func extractImageUsingRegex(pattern: String, string: String, range: Int) -> URL? {

    do {

      let regex = try NSRegularExpression(pattern: pattern)

      guard let match = regex.firstMatch(in: string, options: [], range: string.nsRange),
        match.numberOfRanges >= range else  {

          return nil
      }

      let result = string.substring(nsRange: match.range(at: range))

      return URL(string: result)?.safeScheme()

    } catch {
      log.error("unable to parse imgur image using regex", error: error)
      return nil
    }

  }
}
