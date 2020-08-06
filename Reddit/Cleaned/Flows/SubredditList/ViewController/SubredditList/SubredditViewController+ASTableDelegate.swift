//
//  SubredditViewController+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit

extension SubredditViewController: ASTableDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {

    guard let section = Sections(rawValue: indexPath.section) else { return }

    switch section {
    case .favorite: didSelectFavorite(row: indexPath.row)
    case .default: didSelectDefault(row: indexPath.row)
    case .feeds: didSelectFeed(row: indexPath.row)
    case .subscribed: didSelectSubscribed(row: indexPath.row)
    }

  }

  private func didSelectFavorite(row: Int) {
    let favorite = model.favoriteNames.value[row]
    delegate.didTapSubredditName(favorite)
  }

  private func didSelectDefault(row: Int) {
    let item = model.defaultSubreddits[row].0

    if item.queryable == DefaultSubreddits.random().queryable {
      return delegate.didTapRandom()
    }

    delegate.didTapListing(item)
  }

  private func didSelectFeed(row: Int) {

    let feeds = model.customFeeds.value

    if row >= feeds.count {
      return delegate.didTapToCreateFeed()
    }

    guard let multi = feeds[safe: row] else { return }
    delegate.didTapListing(multi)
  }

  private func didSelectSubscribed(row: Int) {
    guard let subreddit = model.subscribedSubreddits.value[safe: row] else { return }
    delegate.didTapListing(subreddit)
  }

}
