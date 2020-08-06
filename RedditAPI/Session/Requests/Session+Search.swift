//
//  Session+Search.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

public typealias LinkSearchResult = (links: [Link], paginator: Paginator)

extension Session {

  public func searchLinks(
    query: String,
    limitSubreddit: String?,
    sort: SearchSortType,
    time: TimePeriod,
    paginator: Paginator?
  ) -> Promise<LinkSearchResult> {

    let endpoint = Endpoint.searchLinks(
      query: query,
      subreddit: limitSubreddit,
      sort: sort,
      time: time,
      paginator: paginator
    )

    return firstly {
      controller.request(endpoint)

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<Link>>>) -> LinkSearchResult in
      let paginator = response.data.paginator()
      let links = response.data.children.map(\.data)
      return (links, paginator)
    }

  }

  public func searchSubreddits(
    query: String,
    includeNSFW: Bool
  ) -> Promise<[SubredditSearchResult]> {

    firstly { () -> Promise<SubredditSearchResponse> in
      controller.request(.searchSubreddits(query: query, nsfw: includeNSFW))

    }
    .map(\.subreddits)

  }

}
