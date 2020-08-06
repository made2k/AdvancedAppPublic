//
//  URLQueryItem+Additions.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension URLQueryItem {

  static func required(name: String, value: String) -> URLQueryItem {
    return URLQueryItem(name: name, value: value)
  }

  static func optional(name: String, value: String?) -> URLQueryItem? {
    guard let value = value else {
      return nil
    }
    return URLQueryItem(name: name, value: value)
  }

  static func rawJson() -> URLQueryItem {
    URLQueryItem(name: "raw_json", value: "1")
  }

}
