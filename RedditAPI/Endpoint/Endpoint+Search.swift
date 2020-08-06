//
//  Endpoint+Search.swift
//  RedditAPI
//
//  Created by made2k on 3/14/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func searchLinks(
    query: String,
    subreddit: String?,
    sort: SearchSortType,
    time: TimePeriod,
    paginator: Paginator?
  ) -> Endpoint {

    var queryItems: [URLQueryItem] = [
      .required(name: "q", value: query),
      .required(name: "type", value: "link"),
      .required(name: "sort", value: sort.rawValue),
      .required(name: "t", value: time.rawValue),
      URLQueryItem(name: "always_show_media", value: "1"),
      URLQueryItem(name: "feature", value: "link_preview"),
      .optional(name: "after", value: paginator?.after),
      .rawJson()
    ].compactMap { $0 }

    let path: String

    if let subreddit = subreddit {
      queryItems.append(URLQueryItem(name: "restrict_sr", value: "on"))
      path = "/r/\(subreddit)/search.json"

    } else {
      path = "/search.json"
    }

    return Endpoint(
      path: path,
      queryItems: queryItems
    )

  }

  static func searchSubreddits(query: String, nsfw: Bool) -> Endpoint {

    Endpoint(
      path: "/api/search_subreddits.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "query": query,
        "exact": "false",
        "include_over_18": "\(nsfw ? 1 : 0)",
        "include_unadvertisable": "1"
      ]
    )

  }

}
