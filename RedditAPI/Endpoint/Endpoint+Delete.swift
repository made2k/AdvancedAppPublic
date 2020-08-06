//
//  Endpoint+Delete.swift
//  RedditAPI
//
//  Created by made2k on 3/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func delete(_ thing: DeleteType) -> Endpoint {

    Endpoint(
      path: "/api/del.json",
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
