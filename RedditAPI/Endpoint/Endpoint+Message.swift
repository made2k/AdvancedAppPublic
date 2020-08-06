//
//  Endpoint+Message.swift
//  RedditAPI
//
//  Created by made2k on 3/20/20.
//  Copyright © 2020 made2k. All rights reserved.
//

extension Endpoint {

  static func block(_ message: Message) -> Endpoint {

    Endpoint(
      path: "/api/block.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": message.name
      ]
    )

  }

  static func composeMessage(subject: String, body: String, recipient: String) -> Endpoint {

    Endpoint(
      path: "/api/compose.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "api_type": "json",
        "subject": subject,
        "text": body,
        "to": recipient
      ]
    )

  }

  static func deleteMessage(_ message: Message) -> Endpoint {

    Endpoint(
      path: "/api/del_msg.json",
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": message.name
      ]
    )

  }

  static func markMessagesRead(read: Bool, messages: [Message]) -> Endpoint {

    let path = read ? "/api/read_message.json" : "/api/unread_message.json"
    let idList = messages.map(\.name).joined(separator: ",")

    return Endpoint(
      path: path,
      queryItems: [
        .rawJson()
      ],
      httpMethod: .post,
      postData: [
        "id": idList
      ]
    )

  }

  static func messages(type: InboxType, paginator: Paginator?) -> Endpoint {

    Endpoint(
      path: "/message/\(type.rawValue).json",
      queryItems: [
        .optional(name: "after", value: paginator?.after),
        .rawJson()
      ].compactMap { $0 }
    )

  }

  static func submitMessage(parentName: String, body: String) -> Endpoint {

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

}
