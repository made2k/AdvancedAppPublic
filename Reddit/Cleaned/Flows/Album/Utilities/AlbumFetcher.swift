//
//  AlbumFetcher.swift
//  Reddit
//
//  Created by made2k on 3/5/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

class AlbumFetcher: NSObject {
  
  // MARK: - Fetching
  
  static func getAlbum(url: URL) -> Promise<[AlbumImage]> {
    
    let (url, identifier) = clean(url: url)
    
    return firstly {
      primaryFetch(url: url)
      
    }.recover { error -> Promise<[AlbumImage]> in
      guard case AlbumFetchError.primaryLoadFailed = error else { throw error }
      return secondaryFetch(identifier: identifier)
    }
    
  }
  
  private static func primaryFetch(url: URL) -> Promise<[AlbumImage]> {

    return AF.request(url)
      .responseJsonObject(queue: .global())
      .map { try self.parseJsonResponse(json: $0) }
      .recover { _ -> Promise<[AlbumImage]> in throw AlbumFetchError.primaryLoadFailed }

  }
  
  private static func secondaryFetch(identifier: String) -> Promise<[AlbumImage]> {
    
    guard let url = URL(string: "https://imgur.com/gallery/\(identifier)/comment/best/hit.json") else {
      return Promise(error: AlbumFetchError.invalidIdentifier)
    }

    return AF.request(url)
      .responseJsonObject(queue: .global())
      .map { try self.parseJsonResponse(json: $0) }
    
  }
  
  // MARK: - Parse
  
  private static func parseJsonResponse(json: JSON) throws -> [AlbumImage] {

    let data = json["data"]

    guard data.isEmpty == false else {
      throw AlbumFetchError.invalidJson
    }
    
    if let array = data["images"].array ?? data["image"]["album_images"]["images"].array {
      return array.map { AlbumImage(json: $0) }
      
    } else {
      let imageJson = data["image"]
      guard imageJson.isEmpty == false else { return [] }
      return [AlbumImage(json: imageJson)]
    }
    
  }
  
  // MARK: - Clean
  
  static func clean(url: URL) -> (url: URL, identifier: String) {
    var identifier = url.absoluteString.replacingOccurrences(of: "//m.imgur", with: "//imgur")
      .replacingOccurrences(of: "//i.imgur", with: "//imgur")
      .substringOrSelf(after: "https://imgur.com/gallery/")
      .substringOrSelf(after: "https://imgur.com/a/")
      .substringOrSelf(after: "http://imgur.com/gallery/")
      .substringOrSelf(after: "http://imgur.com/a/")
      .substringOrSelf(after: ".com/t/")
      .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
      .substringOrSelf(after: "/", options: .backwards)
    identifier = identifier.substringOrSelf(before: ".")
    
    let cleanedUrl = URL(string: "http://imgur.com/ajaxalbums/getimages/\(identifier)/hit.json").unsafelyUnwrapped
    return (cleanedUrl, identifier)
  }
  
}
