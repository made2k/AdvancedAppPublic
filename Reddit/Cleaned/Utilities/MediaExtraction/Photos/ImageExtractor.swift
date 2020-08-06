//
//  ImageExtractor.swift
//  Reddit
//
//  Created by made2k on 2/25/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RealmSwift
import UIKit

class ImageExtractor: NSObject {
  
  static let shared = ImageExtractor()

  private let realm: Realm?
  
  private override init() {

    do {
      realm = try Realm()

    } catch {
      log.error("Error initializing realm", error: error)
      realm = nil
    }

  }

  func extractImageUrl(url: URL) -> Promise<ImageExtractionResult> {

    if let cache = lookupCache(url) {
      return .value(cache)
    }

    guard let extractor = ImageExtractorFactory.extractor(for: url) else {
      return .error(MediaExtractionError.mediaNotSupported)
    }

    return firstly {
      extractor.extractImage()

    }.get {
      self.saveResults(requestedUrl: url, result: $0)
    }

  }

  func supportsLink(url: URL) -> Bool {
    return SupportedImageExtractionHosts.match(url: url) != nil
  }

  // MARK: - Cache

  private func lookupCache(_ url: URL) -> ImageExtractionResult? {

    guard let realm = realm else { return nil }

    guard let cache = realm
      .objects(ImageExtractorRecord.self)
      .filter("lookup = '\(url.absoluteString)'")
      .first else { return nil }

    guard let url = cache.url else { return nil }
    guard let type = cache.imageType else { return nil }

    return ImageExtractionResult(type: type, url: url)

  }
  
  private func saveResults(requestedUrl: URL, result: ImageExtractionResult) {

    guard let realm = realm else { return }

    let cache = ImageExtractorRecord()
    cache.lookup = requestedUrl.absoluteString
    cache.urlString = result.url.absoluteString
    cache.stringType = result.type.rawValue

    do {
      try realm.write {
        realm.add(cache)
      }
    } catch {
      log.error("Error saving image result cache", error: error)
    }

  }
}
