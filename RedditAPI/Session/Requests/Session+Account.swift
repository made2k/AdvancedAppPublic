//
//  Session+Account.swift
//  RedditAPI
//
//  Created by made2k on 6/21/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {

  public func getAccountInfo(using token: Token) -> Promise<Account> {
    let session: Session

    if token != self.token {
      session = Session()
      session.token = token

    } else {
      session = self
    }

    return session.controller.request(.accountInfo())
  }

  // TODO: Figure out if this takes a paginator or returns one
  public func getSubscribedFeeds(using token: Token, paginator: Paginator) -> Promise<[Feed]> {

    firstly { () -> Promise<[DataResponse<Feed>]> in
      controller.request(.subscribedFeeds(paginator: paginator))

    }.mapValues {
      $0.data
    }

  }

  public func getSubscribedSubreddits(using token: Token, limit: Int = 50, paginator: Paginator) -> Promise<([Subreddit], Paginator)> {

    firstly {
      controller.request(.subscribedSubreddits(limit: limit, paginator: paginator))

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Subreddit>>>) -> ([Subreddit], Paginator) in
      let subreddits = response.data.children.map { $0.data }
      let paginator = response.data.paginator()
      return (subreddits, paginator)
    }

  }

}
