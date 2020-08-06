//
//  SubredditViewController+ASTableDataSource.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension SubredditViewController: ASTableDataSource {

  func numberOfSections(in tableNode: ASTableNode) -> Int {
    return Sections.allCases.count
  }

  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {

    guard let section = Sections(rawValue: section) else { fatalError() }

    switch section {
      // Show favorites or description on adding favorites
    case .favorite: return max(model.favoriteNames.value.count, 1)
    case .default: return model.defaultSubreddits.count

      // If feeds are empty, we'll show the add feed button
    case .feeds:
      guard AccountModel.currentAccount.value.isSignedIn else { return 0 }
      let feeds = model.customFeeds.value
      if feeds.isEmpty && model.loadingFeeds.value { return 1 }

      return feeds.count + 1

    case .subscribed:
      if model.subscribedSubreddits.value.isEmpty {
        return model.loadingSubscribed.value ? 1 : 0
      }
      return model.subscribedSubreddits.value.count
    }

  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

    guard let section = Sections(rawValue: section) else { return nil }

    switch section {
    case .favorite: return R.string.subredditList.favoriteSectionHeader()
    case .default, .feeds, .subscribed: return nil
    }

  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

    guard let section = Sections(rawValue: indexPath.section) else { fatalError() }

    switch section {
    case .favorite: return nodeBlockForFavorite(row: indexPath.row)
    case .default: return nodeBlockForDefault(row: indexPath.row)
    case .feeds: return nodeBlockForFeed(row: indexPath.row)
    case .subscribed: return nodeBlockForSubscribed(row: indexPath.row)
    }

  }

  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

    guard let section = Sections(rawValue: indexPath.section) else { return .none }

    switch section {
    case .default, .favorite:
      return .none

    case .feeds:
      return indexPath.row >= model.customFeeds.value.count ? .none : .delete

    case .subscribed:
      return .delete
    }

  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    guard let section = Sections(rawValue: indexPath.section) else { return }

    switch section {
    case .feeds:
      let feed = model.customFeeds.value[indexPath.row]
      delegate.didDeleteFeed(feed)

    case .subscribed:
      let subscribed = model.subscribedSubreddits.value[indexPath.row]
      delegate.didDeleteSubscribed(subscribed)

    case .default, .favorite: break
    }

  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

    guard let section = Sections(rawValue: indexPath.section) else { return false }

    switch section {
    case .default: return false
    case .subscribed, .feeds: return model.canEditSubscribed
    case .favorite: return true
    }

  }

  // MARK: - Node blocks

  private func nodeBlockForFavorite(row: Int) -> ASCellNodeBlock {

    guard let favorite = model.favoriteNames.value[safe: row] else { return emptyFavoriteCell() }
    let overrideIcon = favoriteIcons[loop: row]

    return {
      SubredditCellNode(
        subredditName: favorite,
        iconUrl: nil,
        overrideImage: overrideIcon,
        backgroundColor: .secondarySystemGroupedBackground
      )
    }

  }

  private func emptyFavoriteCell() -> ASCellNodeBlock {
    return {
      let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
      node.selectionStyle = .none
      node.titleNode.text = R.string.subredditList.favoriteInstructions()
      node.titleNode.alignment = .center
      return node
    }
  }

  private func nodeBlockForDefault(row: Int) -> ASCellNodeBlock {

    let item = model.defaultSubreddits[row]
    let postLoader = item.0
    let image = item.1
    let isRandom = postLoader.queryable == DefaultSubreddits.random().queryable

    return {
      let node = SubredditCellNode(model: postLoader, overrideImage: image, backgroundColor: .secondarySystemGroupedBackground)
      node.hidesFavorite = isRandom
      return node
    }

  }

  private func nodeBlockForFeed(row: Int) -> ASCellNodeBlock {

    let feeds = model.customFeeds.value

    let isLoading = feeds.isEmpty == true && model.loadingFeeds.value
    guard isLoading == false else { return loadingCell() }

    if row == feeds.count { return createFeedCell() }

    let feed = feeds[row]
    let delegate = self.delegate

    return { CustomFeedCellNode(model: feed, delegate: delegate) }

  }

  private func nodeBlockForSubscribed(row: Int) -> ASCellNodeBlock {

    let isLoading = model.subscribedSubreddits.value.isEmpty && model.loadingSubscribed.value
    guard isLoading == false else { return loadingCell() }

    let subreddit = model.subscribedSubreddits.value[row]

    return {
      SubredditCellNode(model: subreddit, overrideImage: nil, backgroundColor: .secondarySystemGroupedBackground)
    }

  }

  private func loadingCell() -> ASCellNodeBlock {
    return {
      LoadingActivityCellNode()
    }
  }

  private func createFeedCell() -> ASCellNodeBlock {
    return {
      let node = ThemeableTextCellNode(backgroundColor: .secondarySystemGroupedBackground)
      node.selectionStyle = .none
      node.style.minHeight = ASDimension(unit: .points, value: 50)
      node.titleNode.text = R.string.subredditList.createNewFeed()
      node.accessoryImage = R.image.icon_add()
      return node
    }
  }

  // MARK: - Helpers

  private var favoriteIcons: [UIImage] {
    return [
      R.image.subreddit_favorite_red().unsafelyUnwrapped,
      R.image.subreddit_favorite_green().unsafelyUnwrapped,
      R.image.subreddit_favorite_yellow().unsafelyUnwrapped,
      R.image.subreddit_favorite_blue().unsafelyUnwrapped,
      R.image.subreddit_favorite_orange().unsafelyUnwrapped
    ]
  }

}
