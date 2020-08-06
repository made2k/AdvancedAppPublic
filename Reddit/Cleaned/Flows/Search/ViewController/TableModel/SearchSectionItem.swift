//
//  SearchSectionItem.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Differentiator
import RedditAPI

enum SearchSectionItem {
  case LinkSectionItem(link: LinkModel?) // Optional to allow for "view all" row
  case UserSectionItem(user: UserModel)
  case SubredditSectionItem(subreddit: SubredditSearchResult)
}

extension SearchSectionItem: IdentifiableType, Equatable {

  typealias Identity = String

  var identity: String {
    
    switch self {
    case .LinkSectionItem(link: let value): return value?.link.id ?? UUID().uuidString
    case .UserSectionItem(user: let value): return value.user.name
    case .SubredditSectionItem(subreddit: let value): return "subreddit:\(value.name)"
    }

  }

  static func == (lhs: SearchSectionItem, rhs: SearchSectionItem) -> Bool {

    switch (lhs, rhs) {

    case (let .LinkSectionItem(link: value1), let .LinkSectionItem(link: value2)):
      if value1 == nil && value2 == nil { return true }
      guard let id1 = value1?.link.id, let id2 = value2?.link.id else { return false }
      return id1 == id2

    case (let .UserSectionItem(user: value1), let .UserSectionItem(user: value2)):
      return value1.username == value2.username

    case (let .SubredditSectionItem(subreddit: value1), let .SubredditSectionItem(subreddit: value2)):
      return value1.name == value2.name

    default:
      return false

    }

  }

}
