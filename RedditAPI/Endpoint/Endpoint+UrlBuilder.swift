//
//  Endpoint+UrlBuilder.swift
//  RedditAPI
//
//  Created by made2k on 3/7/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Foundation

extension Endpoint {

  func authenticatedRequest() throws -> URLRequest {
    try urlRequest(with: authenticatedHost)
  }

  func unauthenticatedRequest() throws -> URLRequest {
    try urlRequest(with: unauthenticatedHost)
  }

  private func urlRequest(with host: String) throws -> URLRequest {

    var components = URLComponents()
    components.scheme = "https"
    components.host = host

    if path.starts(with: "/") {
      components.path = path
    } else {
      components.path = "/\(path)"
    }

    if queryItems.isEmpty == false {
      components.queryItems = queryItems
    }

    let url = try components.asURL()

    var request = URLRequest(
      url: url,
      cachePolicy: .reloadRevalidatingCacheData,
      timeoutInterval: timeoutInterval
    )

    request.httpMethod = httpMethod.rawValue

    guard let postData = postData, httpMethod != .get else {
      return request
    }

    try request.encode(with: postData)

    return request
  }

}
