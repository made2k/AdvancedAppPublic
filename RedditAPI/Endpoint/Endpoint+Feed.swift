//
//  Endpoint+Feed.swift
//  RedditAPI
//
//  Created by made2k on 3/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func addSubreddit(to feed: Feed, subredditName: String) throws -> Endpoint {

    let jsonObject = ["name": subredditName]
    let jsonString = try jsonHeaderString(for: jsonObject)

    return Endpoint(
      path: "/api/multi/\(feed.path)/r/\(subredditName).json",
      queryItems: [],
      httpMethod: .put,
      postData: [
        "model": jsonString
      ]
    )

  }

  static func deleteFeed(_ feed: Feed) -> Endpoint {

    Endpoint(
      path: "/api/multi/\(feed.path).json",
      queryItems: [],
      httpMethod: .delete
    )

  }

  static func removeSubreddit(from feed: Feed, subredditName: String) throws -> Endpoint {

    let jsonObject = ["name": subredditName]
    let jsonString = try jsonHeaderString(for: jsonObject)

    return Endpoint(
      path: "/api/multi/\(feed.path)/r/\(subredditName).json",
      queryItems: [],
      httpMethod: .delete,
      postData: [
        "model": jsonString,
        "srname": subredditName
      ]
    )

  }

  static func updateFeed(
    multiPath: String,
    displayName: String,
    description: String?,
    subredditNames: [String]?
  ) throws -> Endpoint {

    var jsonObject: [String: Any] = [
      "description_md": description ?? "",
      "display_name": displayName,
      "visibility": "private"
    ]
    if let subreddits = subredditNames {
      jsonObject["subreddits"] = subreddits.map { ["name": $0] }
    }

    let jsonString = try jsonHeaderString(for: jsonObject)

    return Endpoint(
      path: "/api/multi\(multiPath).json",
      queryItems: [],
      httpMethod: .put,
      postData: [
        "model": jsonString
      ]
    )

  }

  // MARK: Helper

  private static func jsonHeaderString(for jsonDict: [String: Any]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])

    guard let string = String(data: data, encoding: .utf8) else {
      throw RequestFormatError.invalid
    }

    return string
  }

}
