//
//  Endpoint+EditUserText.swift
//  RedditAPI
//
//  Created by made2k on 3/31/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func editUserText(_ thing: EditableThing, newText: String) -> Endpoint {

    Endpoint(
      path: "/api/editusertext.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "api_type": "json",
        "text": newText,
        "thing_id": thing.name
      ]
    )

  }

}
