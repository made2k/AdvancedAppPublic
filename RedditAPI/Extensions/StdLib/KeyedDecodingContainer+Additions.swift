//
//  KeyedDecodingContainer+Additions.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension KeyedDecodingContainer {

  func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
    try self.decode(T.self, forKey: key)
  }

  func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
    try decodeIfPresent(T.self, forKey: key)
  }

  func decodeUtcDate(_ key: Key) throws -> Date {
    let interval: TimeInterval = try decode(key)
    return Date(timeIntervalSince1970: interval)
  }

  func decodeNonEmptyString(_ key: Key) throws -> String? {
    let value: String = try decode(key)

    guard value.isEmpty == false else {

      let context = DecodingError.Context(
        codingPath: [key],
        debugDescription: "attempt to decode an empty stirng when a non-empty string is required."
      )

      throw DecodingError.dataCorrupted(context)
    }

    return value
  }

  func decodeNonEmptyStringIfPresent(_ key: Key) throws -> String? {

    guard let value: String = try decodeIfPresent(key) else {
      return nil
    }

    guard value.isEmpty == false else {
      return nil
    }

    return value
  }

  func decodeQualifiedUrl(_ key: Key) throws -> URL {

    if
      let url: URL = try? decode(key),
      url.host != nil {
      return url
    }

    let urlString: String = try decode(key)

    var optionalComponents: URLComponents?

    if urlString.hasPrefix("/r/") {
      optionalComponents = URLComponents()
      optionalComponents?.path = urlString

    } else {
      optionalComponents = URLComponents(string: urlString)
    }

    guard var components = optionalComponents else {
      let context = DecodingError.Context(
        codingPath: [key],
        debugDescription: "could not extract a url from given key"
      )
      throw DecodingError.dataCorrupted(context)
    }

    components.scheme = "https"
    components.host = "www.reddit.com"

    return try components.asURL()
  }

  func decodeQualifiedUrlIfPresent(_ key: Key) throws -> URL? {
    return try? decodeQualifiedUrl(key)
  }

  func decodeVoteDirection(_ key: Key) -> VoteDirection {
    let optionalValue: Bool? = try? decode(key)

    guard let value = optionalValue else {
      return .none
    }

    return value ? .up : .down
  }

}
