//
//  Session+Listing.swift
//  RedditAPI
//
//  Created by made2k on 6/23/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

public typealias LinkLoadResponse = (links: [Link], paginator: Paginator)

extension Session {

  public func loadLinks(
    path: String,
    sort: LinkSortType,
    timing: TimePeriod,
    paginator: Paginator?
  ) -> Promise<LinkLoadResponse> {

    let endpoint = Endpoint.loadLinks(
      path: path,
      sort: sort,
      timing: timing,
      paginator: paginator
    )

    return firstly {
      controller.request(endpoint)

    }.map { (response: DataResponse<PagingDataResponse<DataResponse<LinkErasingCommentParser>>>) -> LinkLoadResponse in
      let paginator = response.data.paginator()
      let links = response.data.children.compactMap(\.data.link)
      return (links, paginator)
    }

  }

}
