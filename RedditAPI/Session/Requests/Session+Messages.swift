//
//  Session+Messages.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {

  public func blockViaInbox(message: Message) -> Promise<Void> {

    controller.requestVoid(.block(message))

  }

  // TODO: See what this actually returns
  public func compose(subject: String, body: String, recipient: String) -> Promise<Void> {

    controller
      .requestVoid(
        .composeMessage(
          subject: subject,
          body: body,
          recipient: recipient
        )
      )

  }

  public func delete(message: Message) -> Promise<Void> {

    controller.requestVoid(.deleteMessage(message))

  }

  public func getMessages(type: InboxType, paginator: Paginator?) -> Promise<([Message], Paginator)> {

    firstly {
      controller.request(.messages(type: type, paginator: paginator))

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Message>>>) -> ([Message], Paginator) in
      let paginator = response.data.paginator()
      let messages = response.data.children.map { $0.data }
      return (messages, paginator)
    }

  }

  public func setMessageReadStatus(read: Bool, messages: [Message]) -> Promise<Void> {

    controller.requestVoid(.markMessagesRead(read: read, messages: messages))

  }

}
