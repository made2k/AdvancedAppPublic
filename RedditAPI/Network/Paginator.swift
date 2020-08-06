//
//  Paginator.swift
//  RedditAPI
//
//  Created by made2k on 6/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

public struct Paginator {

  public static func none() -> Paginator {
    return Paginator(before: nil, after: nil)
  }

  let before: String?
  let after: String?

  public var hasMore: Bool {
    return after != nil
  }

}
