//
//  QuickSwitchCoordinator+TableViewReorderDelegate.swift
//  Reddit
//
//  Created by made2k on 12/31/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Haptica
import SwiftReorder
import UIKit

extension QuickSwitchCoordinator: TableViewReorderDelegate {

  func tableView(_ tableView: UITableView,
                 targetIndexPathForReorderFromRowAt sourceIndexPath: IndexPath,
                 to proposedDestinationIndexPath: IndexPath) -> IndexPath {

    let section = favoritesSection.unsafelyUnwrapped

    if sourceIndexPath.section != proposedDestinationIndexPath.section {
      return IndexPath(row: tableView.numberOfRows(inSection: section) - 1, section: section)
    }

    return proposedDestinationIndexPath
  }

  func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    let favoriteSection = favoritesSection.unsafelyUnwrapped

    guard sourceIndexPath.row >= 0 else { return }
    guard destinationIndexPath.row < tableView.numberOfRows(inSection: favoriteSection) else { return }

    Haptic.selection.generate()

    var favorites = Settings.favoriteSubreddits.value

    let item = favorites.remove(at: sourceIndexPath.row)
    favorites.insert(item, at: destinationIndexPath.row)

    Settings.favoriteSubreddits.accept(favorites)
  }

  func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
    return indexPath.section == favoritesSection
  }

  func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
    Haptic.impact(.light).generate()
  }
}
