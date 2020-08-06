//
//  LiveCommentsCoordinator+LiveCommentModelDelegate.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import CoreGraphics
import Foundation

extension LiveCommentsCoordinator: LiveCommentModelDelegate {

  func didFetchComments(comments: [CommentModel]) {

    guard let tableNode = controller?.tableNode else { return }

    let indexPaths = (0..<comments.count).map { IndexPath(row: $0, section: 0) }

    if tableNode.contentOffset.y > 120 {
      addAndAdjustOffset(indexPaths)

    } else {
      tableNode.insertRows(at: indexPaths, with: .top)
    }

    // If first load, scroll to top
    if comments.count == model.comments.count {
      tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

  }

  func commentAddedAt(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    controller?.tableNode.insertRows(at: [indexPath], with: .top)
  }

  private func addAndAdjustOffset(_ addedIndexes: [IndexPath]) {
    guard let tableNode = controller?.tableNode else { return }

    let updates: () -> Void = {
      tableNode.insertRows(at: addedIndexes, with: .none)
    }

    let currentOffset = tableNode.contentOffset.y

    tableNode.performBatch(animated: false, updates: updates) { _ in
      var size: CGFloat = 0.0

      addedIndexes.forEach { index in
        guard let node = tableNode.nodeForRow(at: index) else { return }
        size += node.calculatedSize.height
      }

      tableNode.setContentOffset(CGPoint(x: 0, y: currentOffset + size), animated: false)
    }
  }

}
