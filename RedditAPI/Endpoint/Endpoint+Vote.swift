//
//  Endpoint+Vote.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func vote(_ direction: VoteDirection, thing: VoteType) -> Endpoint {

    Endpoint(
      path: "/api/vote.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": thing.name,
        "dir": "\(direction.rawValue)"
      ]
    )

  }

}
