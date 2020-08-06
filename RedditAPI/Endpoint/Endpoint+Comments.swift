//
//  Endpoint+Comments.swift
//  RedditAPI
//
//  Created by made2k on 3/15/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func fetchComments(link: Link, sort: CommentSort, limit: Int) -> Endpoint {

    Endpoint(
      path: "/r/\(link.subreddit)/comments/\(link.id).json",
      queryItems: [
        URLQueryItem(name: "sort", value: sort.rawValue),
        URLQueryItem(name: "limit", value: "\(limit)"),
        .rawJson()
      ]
    )

  }

  static func loadMore(childrenIds: [String], sort: CommentSort, linkName: String) -> Endpoint {

    Endpoint(
      path: "/api/morechildren.json",
      queryItems: [
        URLQueryItem(name: "api_type", value: "json"),
        URLQueryItem(name: "children", value: childrenIds.joined(separator: ",")),
        URLQueryItem(name: "sort", value: sort.rawValue),
        URLQueryItem(name: "link_id", value: linkName),
        .rawJson()
      ]
    )

  }

  static func submitComment(parentName: String, body: String) -> Endpoint {

    Endpoint(
      path: "/api/comment.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "api_type": "json",
        "text": body,
        "thing_id": parentName
      ]
    )

  }

  static func userComments(username: String, sort: CommentSort, time: TimePeriod, paginator: Paginator) -> Endpoint {

    Endpoint(
      path: "/user/\(username)/comments.json",
      queryItems: [
        URLQueryItem(name: "sort", value: sort.rawValue),
        URLQueryItem(name: "t", value: "\(time.rawValue)"),
        URLQueryItem(name: "show", value: "all"),
        .optional(name: "after", value: paginator.after),
        .rawJson()
      ].compactMap { $0 }
    )

  }

}
