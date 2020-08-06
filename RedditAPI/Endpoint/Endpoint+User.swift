//
//  Endpoint+User.swift
//  RedditAPI
//
//  Created by made2k on 3/8/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func userProfile(_ username: String) -> Endpoint {

    Endpoint(
      path: "/user/\(username)/about.json",
      queryItems: [
        .rawJson()
      ]
    )

  }

  static func topKarmaSubreddits(_ username: String) -> Endpoint {

    Endpoint(
      path: "/user/\(username)/top_karma_subreddits.json",
      queryItems: [
        URLQueryItem(name: "limit", value: "10"),
        .rawJson()
      ]
    )

  }

  static func trophies(_ username: String) -> Endpoint {

    Endpoint(
      path: "/user/\(username)/trophies.json",
      queryItems: [
        .rawJson()
      ]
    )

  }

}
