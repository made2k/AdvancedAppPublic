//
//  Endpoint+Account.swift
//  RedditAPI
//
//  Created by made2k on 3/7/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func accountInfo() -> Endpoint {

    Endpoint(
      path: "/api/v1/me.json",
      queryItems: [
        .rawJson()
      ]
    )

  }

  static func subscribedFeeds(paginator: Paginator) -> Endpoint {

    Endpoint(
      path: "/api/multi/mine.json",
      queryItems: [
        URLQueryItem(name: "expand_srs", value: "0"),
        URLQueryItem(name: "after", value: paginator.after),
        .rawJson()
      ]
    )

  }

  static func subscribedSubreddits(limit: Int = 50, paginator: Paginator) -> Endpoint {

    Endpoint(
      path: "/subreddits/mine/subscriber.json",
      queryItems: [
        .required(name: "limit", value: "\(limit)"),
        .optional(name: "after", value: paginator.after),
        .rawJson()
      ].compactMap { $0 }
    )

  }

}
