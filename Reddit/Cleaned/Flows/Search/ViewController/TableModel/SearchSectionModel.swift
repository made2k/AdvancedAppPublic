//
//  SearchSectionModel.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Differentiator
import RxASDataSources

/**
 Search sections consist of Links, Users, and Subreddits when applicable.
 */
enum SearchSectionModel {
  case LinkProvidableSection(title: String, items: [SearchSectionItem])
  case UserProvidableSection(title: String, items: [SearchSectionItem])
  case SubredditProvidableSection(title: String, items: [SearchSectionItem])

  var title: String {

    switch self {
    case .LinkProvidableSection(title: let title, items: _): return title
    case .UserProvidableSection(title: let title, items: _): return title
    case .SubredditProvidableSection(title: let title, items: _): return title
    }

  }

}

extension SearchSectionModel: SectionModelType {

  typealias Item = SearchSectionItem

  var items: [SearchSectionItem] {

    switch  self {
    case .LinkProvidableSection(title: _, items: let items): return items
    case .UserProvidableSection(title: _, items: let items): return items
    case .SubredditProvidableSection(title: _, items: let items): return items
    }

  }

  init(original: SearchSectionModel, items: [Item]) {

    switch original {

    case let .LinkProvidableSection(title: title, items: _):
      self = .LinkProvidableSection(title: title, items: items)

    case let .UserProvidableSection(title, _):
      self = .UserProvidableSection(title: title, items: items)

    case let .SubredditProvidableSection(title, _):
      self = .SubredditProvidableSection(title: title, items: items)

    }
  }

}

extension SearchSectionModel: AnimatableSectionModelType {

  typealias Identity = String

  var identity: String {

    switch self {
    case .LinkProvidableSection(title: _, items: _): return "link"
    case .UserProvidableSection(title: _, items: _): return "user"
    case .SubredditProvidableSection(title: _, items: _): return "subreddit"
    }

  }

}
