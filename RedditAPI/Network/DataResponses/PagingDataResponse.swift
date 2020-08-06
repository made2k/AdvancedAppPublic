//
//  PagingDataResponse.swift
//  RedditAPI
//
//  Created by made2k on 3/15/20.
//  Copyright © 2020 made2k. All rights reserved.
//

struct PagingDataResponse<T: Decodable>: Decodable {

  let after: String?
  let before: String?
  let children: [T]

  func paginator() -> Paginator {
    return Paginator(before: before, after: after)
  }

}
