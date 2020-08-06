//
//  Endpoint+Link.swift
//  RedditAPI
//
//  Created by made2k on 3/20/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func fullLink(
    subredditName: String,
    linkName: String,
    postTitle: String,
    focusId: String?,
    context: String?
  ) -> Endpoint {

    Endpoint(
      path: "/r/\(subredditName)/comments/\(linkName)/\(postTitle)/\(focusId ?? "").json",
      queryItems: [
        .optional(name: "context", value: context),
        .rawJson()
      ].compactMap { $0 }
    )

  }

  static func loadLinks(
    path: String,
    sort: LinkSortType,
    timing: TimePeriod,
    paginator: Paginator?
  ) -> Endpoint {

    var path = path
    if path.hasSuffix(".json") == false {
      path = "\(path).json"
    }
    
    return Endpoint(
      path: path,
      queryItems: [
        .required(name: "sort", value: sort.rawValue),
        .required(name: "t", value: timing.rawValue),
        URLQueryItem(name: "show", value: "all"),
        URLQueryItem(name: "always_show_media", value: "1"),
        .optional(name: "after", value: paginator?.after),
        .rawJson()
      ].compactMap { $0 }
    )

  }

  static func markVisited(_ links: [Link]) -> Endpoint {

    let linkList: String = links.map(\.name).joined(separator: ",")

    return Endpoint(
      path: "/api/store_visits",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "links": linkList
      ]
    )

  }

  static func setHidden(_ hidden: Bool, names: [String]) -> Endpoint {

    let path = hidden ? "/api/hide" : "/api/unhide"

    let ids = names.joined(separator: ",")

    return Endpoint(
      path: path,
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": ids
      ]
    )

  }

  static func shortLink(linkName: String) -> Endpoint {

    Endpoint(
      authenticatedHost: "redd.it",
      unauthenticatedHost: "redd.it",
      path: "/\(linkName)",
      queryItems: [
        .rawJson()
      ]
    )

  }

  static func submitLink(
    subredditName: String,
    title: String,
    url: URL,
    sendReplies: Bool
  ) -> Endpoint {

    Endpoint(
      path: "/api/submit",
      queryItems: [],
      httpMethod: .post,
      postData: [
        "api_type": "json",
        "sr": subredditName,
        "kind": "link",
        "title": title,
        "sendreplies": sendReplies,
        "url": url
      ]
    )

  }

  static func submitSelfpost(
    subredditName: String,
    title: String,
    text: String,
    sendReplies: Bool
  ) -> Endpoint {

    Endpoint(
      path: "/api/submit",
      queryItems: [],
      httpMethod: .post,
      postData: [
        "api_type": "json",
        "kind": "self",
        "resubmit": true,
        "sendreplies": sendReplies,
        "sr": subredditName,
        "text": text,
        "title": title
      ]
    )

  }

}
