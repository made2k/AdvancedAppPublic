//
//  Endpoint.swift
//  RedditAPI
//
//  Created by made2k on 3/7/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct Endpoint {
  var authenticatedHost: String = "oauth.reddit.com"
  var unauthenticatedHost: String = "www.reddit.com"

  let path: String
  let queryItems: [URLQueryItem]

  var httpMethod: HTTPMethod = .get
  var postData: [String: Encodable]?

  var timeoutInterval: TimeInterval = 10.0
}
