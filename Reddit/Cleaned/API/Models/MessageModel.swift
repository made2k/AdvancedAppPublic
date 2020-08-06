//
//  MessageContainer.swift
//  Reddit
//
//  Created by made2k on 1/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class MessageModel: ViewModel, ReadModelType {

  private(set) lazy var author = Observable<String>.just(message.author)
  private(set) lazy var bodyHtml = Observable<String>.just(message.bodyHtml)
  private(set) lazy var subject = Observable<String>.just(message.subject)

  private let readRelay = BehaviorRelay<Bool>(value: false)
  private(set) lazy var readObserver = readRelay.asObservable()
  var read: Bool { return readRelay.value }

  let message: Message
  
  init(_ message: Message) {
    self.message = message
    super.init()
    copyValues(from: message)
  }

  func block() -> Promise<Void> {
    return api.session.blockViaInbox(message: message)
  }

  func markRead() -> Promise<Void> {
    guard readRelay.value == false else { return .value(()) }

    readRelay.accept(true)

    return firstly {
      api.session.setMessageReadStatus(read: true, messages: [message])

    }.recover {
      log.error("failed to mark message as read", error: $0)
      self.readRelay.accept(false)
      throw $0
    }

  }

  func markUnread() -> Promise<Void> {

    guard readRelay.value else { return .value(()) }

    readRelay.accept(false)

    return firstly {
      api.session.setMessageReadStatus(read: true, messages: [message])

    }.recover {
      log.error("failed to mark message as unread", error: $0)
      self.readRelay.accept(true)
      throw $0
    }

  }

  func delete() -> Promise<Void> {
    return api.session.delete(message: message)
  }

  private func copyValues(from message: Message) {
    let isRead = message.new == false
    readRelay.accept(isRead)
  }
  
}
