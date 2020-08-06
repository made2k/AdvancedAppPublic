//
//  InboxModel.swift
//  Reddit
//
//  Created by made2k on 4/25/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

class InboxModel: ViewModel {

  private let inboxTypeRelay = BehaviorRelay<InboxType>(value: InboxType.inbox)
  private(set) lazy var inboxTypeObserver: Observable<InboxType> =
    inboxTypeRelay.asObservable()
  var inboxType: InboxType { return inboxTypeRelay.value }

  private(set) var messages: [MessageModel] = []

  private var paginator: Paginator? = nil
  
  var canLoadMore: Bool {
    if messages.isEmpty && paginator == nil {
      return true
    }

    if let paginator = paginator {
      return paginator.hasMore
    }

    return false
  }
  
  func reset() {
    paginator = nil
    messages.removeAll()
  }
  
  func setType(_ type: InboxType) {
    reset()
    inboxTypeRelay.accept(type)
  }
  
  func delete(at index: Int) {
    let message = messages.remove(at: index)
    
    message.delete().catch {
      log.error($0)
    }

  }

  func getMessages() -> Promise<[MessageModel]> {

    guard AccountModel.currentAccount.value.isSignedIn else {
      return .error(APIError.notSignedIn)
    }

    if let paginator = paginator {

      guard paginator.hasMore else {
        return .value([])
      }

    }

    return firstly {
      api.session.getMessages(type: inboxType, paginator: paginator)

    }.get {
      self.paginator = $0.1

    }.map {
      $0.0

    }.mapValues {
      MessageModel($0)

    }.get {
      self.messages.append(contentsOf: $0)
    }

  }
  
  func composeMessage(recipient: String, subject: String, body: String) -> Promise<Void> {
    return api.session.compose(subject: subject, body: body, recipient: recipient)
  }
  
}

