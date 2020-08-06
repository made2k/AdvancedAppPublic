//
//  Session+Feeds.swift
//  RedditAPI
//
//  Created by made2k on 6/27/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension Session {
  
  // MARK: - Feed editing
  
  public func addSubreddit(feed: Feed, subredditName: String) -> Promise<Void> {

    firstly {
      try controller.requestVoid(.addSubreddit(to: feed, subredditName: subredditName))
    }

  }

  public func deleteFeed(feed: Feed) -> Promise<Void> {
    controller.requestVoid(.deleteFeed(feed))
  }

  public func performFeedUpdate(feedPath: String?, displayName: String, description: String?, subreddits: [String]?) -> Promise<Feed> {

    guard let name = token?.name else {
      return .init(error: APIError.notSignedIn)
    }

    let path = feedPath ?? "/user/\(name)/m/\(displayName)"

    return firstly {

      try controller
        .request(
          .updateFeed(
            multiPath: path,
            displayName: displayName,
            description: description,
            subredditNames: subreddits
          )
        )

    }.map { (response: DataResponse<Feed>) -> Feed in
      return response.data
    }

  }

  public func removeSubreddit(feed: Feed, subredditName: String) -> Promise<Void> {

    firstly {
      try controller.requestVoid(.removeSubreddit(from: feed, subredditName: subredditName))
    }

  }

}
