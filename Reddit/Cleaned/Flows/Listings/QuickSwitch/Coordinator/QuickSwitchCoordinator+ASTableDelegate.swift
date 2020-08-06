//
//  QuickSwitchCoordinator+ASTableDelegate.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit
import RedditAPI
import UIKit

extension QuickSwitchCoordinator: UITableViewDelegate {

  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    UISelectionFeedbackGenerator().selectionChanged()

    switch indexPath.section {

    case favoritesSection:
      let subredditName = Settings.favoriteSubreddits.value[indexPath.row]
      if subredditName ~== "front" {
        openSubreddit(model: DefaultSubreddits.front())

      } else {
        openSubreddit(queryString: subredditName)
      }

    case subscribedSection:
      if let model = subscribedSubreddits.value[safe: indexPath.row] {
        openSubreddit(model: model)
      }

    case searchResultsSection:
      if let subredditName = searchResults.value?[safe: indexPath.row]?.name {
        openSubreddit(subredditName: subredditName)
      }

    case feedSection:
      let feeds: [FeedModel] = AccountModel.currentAccount.value.feeds.value
      let feed: FeedModel = feeds[indexPath.row]
      openFeed(model: feed)

    default:
      break
    }

  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    switch section {
      
    case favoritesSection:
      return ThemedTableSectionHeader(title: R.string.quickSwitch.favoriteSectionHeader())

    case searchResultsSection:
      return ThemedTableSectionHeader(title: R.string.quickSwitch.searchResultsSectionHeader())

    case subscribedSection:
      return ThemedTableSectionHeader(title: R.string.quickSwitch.subscribedSectionHeader())

    case subscribedSection:
      return ThemedTableSectionHeader(title: R.string.quickSwitch.subscribedSectionHeader())

    case feedSection:
      return ThemedTableSectionHeader(title: R.string.quickSwitch.feedSectionHeader())

    default:
      return nil
    }
  }

  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 25
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == feedSection { return false }
    if indexPath.section == subscribedSection, subscribedSubreddits.value.isEmpty {
      return false
    }
    return true
  }

  func tableView(
    _ tableView: UITableView,
    commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {

    guard indexPath.section == favoritesSection else { return }

    Settings.favoriteSubreddits.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }

  func tableView(
    _ tableView: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    switch indexPath.section {

    case favoritesSection:
      return favoriteSectionConfiguration(tableView: tableView, indexPath: indexPath)

    case subscribedSection:
      return subscribedSectionConfiguration(tableView: tableView, indexPath: indexPath)

    case searchResultsSection:
      return searchResultSectionConfiguration(tableView: tableView, indexPath: indexPath)

    default:
      return nil
    }

  }

  // MARK: - Action Helpers

  /// Actions are only to remove favorite.
  private func favoriteSectionConfiguration(
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {

    let name = Settings.favoriteSubreddits.value[indexPath.row]
    let action = removeFavoriteAction(tableView: tableView, indexPath: indexPath, favoriteName: name)

    return UISwipeActionsConfiguration(actions: [action].compactMap { $0 })
  }

  /// Actions is Unsubscribe and one of "Add favorite" or "Remove favorite"
  private func subscribedSectionConfiguration(
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {

    let model = subscribedSubreddits.value[indexPath.row]
    let unsubAction = unsubscribeAction(tableView: tableView, indexPath: indexPath, model: model)

    let isFavorite = Settings.favoriteSubreddits.value.contains(where: { $0 ~== model.queryable })

    if isFavorite {
      let unFavoriteAction = removeFavoriteAction(tableView: tableView,
                                                  indexPath: indexPath,
                                                  favoriteName: model.title)
      return UISwipeActionsConfiguration(actions: [unsubAction, unFavoriteAction].compactMap { $0 })

    } else {
      let favoriteAction = AddFavoriteAction(tableView: tableView, newFavorite: model.title)
      return UISwipeActionsConfiguration(actions: [unsubAction, favoriteAction])
    }

  }

  /// Actions will be sub or unsub, and favorite or unfavorite
  private func searchResultSectionConfiguration(
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {

    guard let result = searchResults.value?[indexPath.row] else { return nil }

    let favoriteAction: UIContextualAction?
    let subAction: UIContextualAction

    let subscribedModel = subscribedSubreddits.value.first { $0.queryable ~== result.name }
    let isFavorite = Settings.favoriteSubreddits.value.contains { $0 ~== result.name }

    if let model = subscribedModel {
      subAction = unsubscribeAction(tableView: tableView, indexPath: indexPath, model: model)

    } else {
      subAction = subscribeAction(tableView: tableView, indexPath: indexPath, model: result)
    }

    if isFavorite {
      favoriteAction = removeFavoriteAction(tableView: tableView, indexPath: indexPath, favoriteName: result.name)

    } else {
      favoriteAction = AddFavoriteAction(tableView: tableView, newFavorite: result.name)
    }

    return UISwipeActionsConfiguration(actions: [favoriteAction, subAction].compactMap { $0 })
  }

  // MARK: Favorites

  private func removeFavoriteAction(
    tableView: UITableView,
    indexPath: IndexPath,
    favoriteName: String
  ) -> UIContextualAction? {

    guard let favoriteIndex = Settings.favoriteSubreddits.value.firstIndex(where: { $0 ~== favoriteName }) else {
      return nil
    }

    let action = UIContextualAction(style: .destructive, title: "Remove Favorite") { (_, _, success) in
      Settings.favoriteSubreddits.remove(at: favoriteIndex)

      if indexPath.section == self.favoritesSection {
        tableView.deleteRows(at: [indexPath], with: .automatic)
        success(true)
      } else {
        success(false)
      }

    }
    action.backgroundColor = R.color.favoriteRemoveBackground()

    return action
  }

  private func AddFavoriteAction(tableView: UITableView, newFavorite: String) -> UIContextualAction {

    let action = UIContextualAction(style: .normal, title: "Add Favorite") { (_, _, handler) in
      Settings.favoriteSubreddits.append(newFavorite)

      if let section = self.favoritesSection {
        let indexPath = IndexPath(row: Settings.favoriteSubreddits.value.count - 1, section: section)
        tableView.insertRows(at: [indexPath], with: .automatic)
        handler(true)
      } else {
        handler(false)
      }

    }

    action.backgroundColor = R.color.favoriteAddBackground()
    return action
  }

  // MARK: Subscriptions
  
  private func unsubscribeAction(
    tableView: UITableView,
    indexPath: IndexPath,
    model: SubredditModel
  ) -> UIContextualAction {

    let action = UIContextualAction(style: .destructive, title: "Unsubscribe") { (_, _, handler) in
      Overlay.shared.showProcessingOverlay()

      firstly {
        after(seconds: 0.3)

      }.then { _ -> Promise<Void> in
        model.unsubscribe()

      }.done {
        if indexPath.section == self.subscribedSection {
          var subscribedArray = self.subscribedSubreddits.value
          subscribedArray.remove(at: indexPath.row)
          self.subscribedSubreddits.accept(subscribedArray)
        }

      }.done {
        Overlay.shared.hideProcessingOverlay()
        handler(true)

      }.catch { _ in
        Overlay.shared.flashErrorOverlay("There was a problem unsubscribing.")
        handler(false)
      }

    }
    action.backgroundColor = R.color.offRed()
    return action
  }

  private func subscribeAction(
    tableView: UITableView,
    indexPath: IndexPath,
    model: SubredditSearchResult
  ) -> UIContextualAction {

    let action = UIContextualAction(style: .normal, title: "Subscribe") { (_, _, handler) in
      Overlay.shared.showProcessingOverlay()

      firstly {
        after(seconds: 0.3)

      }.then { _ -> Promise<SubredditModel> in
        SubredditModel.verifySubredditExists(path: model.name)

      }.then { subreddit -> Promise<SubredditModel> in
        subreddit.subscribe().map { subreddit }

      }.map { model -> [SubredditModel] in
        var subscribed = self.subscribedSubreddits.value
        subscribed.append(model)
        return subscribed

      }.map { subscribed -> [SubredditModel] in
        return subscribed.sorted(by: { $0.title.caseInsensitiveCompare($1.title) == .orderedAscending })

      }.done {
        self.subscribedSubreddits.accept($0)

      }.done { _ in
        Overlay.shared.hideProcessingOverlay()
        handler(true)

      }.catch { _ in
        Overlay.shared.flashErrorOverlay("There was a problem subscribing.")
        handler(false)
      }

    }

    return action
  }

}
