//
//  Endpoint+Token.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {
  
  static func accessToken(postData: [String: Encodable]) -> Endpoint {
    
    Endpoint(
      authenticatedHost: "www.reddit.com",
      path: "/api/v1/access_token",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: postData
    )
    
  }
  
}
