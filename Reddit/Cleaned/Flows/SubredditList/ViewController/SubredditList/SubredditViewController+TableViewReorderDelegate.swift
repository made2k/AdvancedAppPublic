//
//  SubredditViewController+TableViewReorderDelegate.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import RxSwift
import SwiftReorder
import UIKit

extension SubredditViewController: TableViewReorderDelegate {

  func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
    UIImpactFeedbackGenerator().impactOccurred()
    reorderingDisposeBag = DisposeBag()
  }

  func tableViewDidFinishReordering(_ tableView: UITableView,
                                    from initialSourceIndexPath: IndexPath,
                                    to finalDestinationIndexPath: IndexPath) {
    UIImpactFeedbackGenerator().impactOccurred()
    setupReorderBoundBindings(skipCount: 1)
  }

  func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {

    guard let section = Sections(rawValue: indexPath.section) else { return false }

    switch section {
    case .favorite: return true
    case .default, .feeds, .subscribed: return false
    }

  }

  func tableView(_ tableView: UITableView, targetIndexPathForReorderFromRowAt sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath {

    // Make sure we're reording within the same section, otherwise limit to section limit
    guard sourceIndexPath.section == proposedDestinationIndexPath.section else {
      let targetRow: Int = proposedDestinationIndexPath.section < sourceIndexPath.section ?
        0 :
        tableView.numberOfRows(inSection: sourceIndexPath.section) - 1

      return IndexPath(row: targetRow, section: sourceIndexPath.section)
    }

    return proposedDestinationIndexPath
  }

  func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    guard sourceIndexPath.row >= 0 else { return }
    guard destinationIndexPath.row < tableView.numberOfRows(inSection: sourceIndexPath.section) else { return }

    Haptic.selection.generate()

    var favoritesCopy = Settings.favoriteSubreddits.value
    let movedItem = favoritesCopy.remove(at: sourceIndexPath.row)
    favoritesCopy.insert(movedItem, at: destinationIndexPath.row)

    Settings.favoriteSubreddits.accept(favoritesCopy)
  }

}
