//
//  Session+Subreddit.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {
  
  public func getDefaultSubreddits(paginator: Paginator) -> Promise<([Subreddit], Paginator)> {

    firstly {
      controller.request(.defaultSubreddits(paginator: paginator))

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Subreddit>>>) -> ([Subreddit], Paginator) in
      let subreddits = response.data.children.map(\.data)
      let paginator = response.data.paginator()
      return (subreddits, paginator)
    }

  }
  
  public func getSubredditInfo(_ subreddit: Subreddit) -> Promise<Subreddit> {
    getSubredditInfo(subredditName: subreddit.displayName)
  }
  
  public func getSubredditInfo(subredditName: String) -> Promise<Subreddit> {

    firstly { () -> Promise<DataResponse<Subreddit>> in
      controller.request(.subredditInfo(name: subredditName))

    }
    .map(\.data)

  }

  public func randomSubreddit() -> Promise<Subreddit> {

    firstly {
      controller.request(.random())

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Link>>>) -> String in
      guard let link = response.data.children.first?.data else {
        throw APIError.badResponse
      }
      return link.subreddit

    }.then { (subreddit: String) -> Promise<Subreddit> in
      self.getSubredditInfo(subredditName: subreddit)
    }

  }

  public func setSubscribed(_ subscribe: Bool, subreddit: Subreddit) -> Promise<Void> {

    controller.requestVoid(.updateSubscription(subscribed: subscribe, subreddit: subreddit))

  }

}
