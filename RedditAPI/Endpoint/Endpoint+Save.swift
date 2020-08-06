//
//  Endpoint+Save.swift
//  RedditAPI
//
//  Created by made2k on 4/1/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func setSaved(_ saved: Bool, thing: SaveType) -> Endpoint {

    let path = saved ? "/api/save.json" : "/api/unsave.json"

    return Endpoint(
      path: path,
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": thing.name
      ]
    )

  }

}
