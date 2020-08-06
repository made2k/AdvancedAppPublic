//
//  Endpoint+Subreddit.swift
//  RedditAPI
//
//  Created by made2k on 3/15/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func defaultSubreddits(paginator: Paginator) -> Endpoint {

    Endpoint(
      path: "/subreddits/default.json",
      queryItems: [
        .optional(name: "after", value: paginator.after),
        .rawJson()
      ].compactMap { $0 }
    )

  }

  static func subredditInfo(name: String) -> Endpoint {

    Endpoint(
      path: "/r/\(name)/about.json",
      queryItems: [
        .rawJson()
      ]
    )

  }

  static func updateSubscription(subscribed: Bool, subreddit: Subreddit) -> Endpoint {
    
    Endpoint(
      path: "/api/subscribe.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "action": subscribed ? "sub" : "unsub",
        "sr": subreddit.name
      ]
    )
    
  }

  static func random() -> Endpoint {

    Endpoint(
      path: "/r/random",
      queryItems: [
        .rawJson()
      ]
    )

  }

}
