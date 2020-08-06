//
//  Session+User.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

public typealias UserCommentResponse = (data: [Comment], paginator: Paginator)

extension Session {

  public func getActiveSubreddits(user: User) -> Promise<[KarmaListSubreddit]> {

    firstly { () -> Promise<DataResponse<[KarmaListSubreddit]>> in
      controller.request(.topKarmaSubreddits(user.name))

    }
    .map(\.data)

  }

  public func getUserProfile(username: String) -> Promise<User> {

    firstly { () -> Promise<DataResponse<User>> in
      controller.request(.userProfile(username))

    }
    .map(\.data)

  }

  public func getTrophies(user: User) -> Promise<[Trophy]> {

    firstly { () -> Promise<DataResponse<TrophyCollection>> in
      controller.request(.trophies(user.name))

    }
    .map(\.data.trophies)
    .mapValues(\.data)

  }

  public func loadUserComments(user: User, sort: CommentSort, time: TimePeriod, paginator: Paginator) -> Promise<UserCommentResponse> {

    firstly {
      controller
        .request(
          .userComments(
          username: user.name,
          sort: sort,
          time: time,
          paginator: paginator
          )
        )

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Comment>>>) -> UserCommentResponse in
      let paginator = response.data.paginator()
      let comments = response.data.children.map(\.data)
      return (comments, paginator)
    }
    
  }

}
