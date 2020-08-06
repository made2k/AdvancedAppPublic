//
//  QuickSwitchCoordinator+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

extension QuickSwitchCoordinator {

  var searchResultsSection: Int? {
    if searchResults.value != nil { return 0 }
    return nil
  }
  var favoritesSection: Int? {
    guard searchResults.value == nil else { return nil }
    guard Settings.favoriteSubreddits.isNotEmpty else { return nil }
    return 0
  }
  var subscribedSection: Int? {
    guard searchResults.value == nil else { return nil }
    if let feedSection = feedSection {
      return feedSection + 1
    }
    if let favoriteSection = favoritesSection {
      return favoriteSection + 1
    }
    return 0
  }
  var feedSection: Int? {
    guard searchResults.value == nil else { return nil }
    guard AccountModel.currentAccount.value.feeds.value.isNotEmpty else { return nil }
    if let favoriteSection = favoritesSection {
      return favoriteSection + 1
    }
    return 0
  }

  private func subredditName(at indexPath: IndexPath) -> String? {

    switch indexPath.section {

    case favoritesSection:
      return Settings.favoriteSubreddits.value[safe: indexPath.row]

    case searchResultsSection:
      return searchResults.value.unsafelyUnwrapped[safe: indexPath.row]?.name

    case subscribedSection:
      return subscribedSubreddits.value[safe: indexPath.row]?.title

    case feedSection:
      let feeds: [FeedModel] = AccountModel.currentAccount.value.feeds.value
      return feeds[safe: indexPath.row]?.feed.displayName

    default:
      fatalError("IndexPath mismatch")
    }

  }

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    // If search results, that is the only section
    if searchResults.value != nil { return 1 }

    var sectionCount: Int = 0

    if let _ = favoritesSection {
      sectionCount += 1
    }

    if let _ = feedSection {
      sectionCount += 1
    }

    if let _ = subscribedSection {
      sectionCount += 1
    }

    return sectionCount
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

    switch section {

    case favoritesSection:
      return Settings.favoriteSubreddits.value.count

    case searchResultsSection:
      return searchResults.value?.count ?? 0

    case feedSection:
      let feeds: [FeedModel] = AccountModel.currentAccount.value.feeds.value
      return feeds.count

    case subscribedSection:
      // If no subreddits, show the "Loading..." cell
      // TODO: If there's no subscribed, we need to show 0
      return max(subscribedSubreddits.value.count, 1)

    default:
      return 0
    }

  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let title = subredditName(at: indexPath) ?? "Loading..."
    
    return {
      QuickSwitchTableCellNode(title: title)
    }
  }

}
