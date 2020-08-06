//
//  InboxViewController+ASBatchFetchingDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import AsyncDisplayKit
import PromiseKit

extension InboxViewController: ASBatchFetchingDelegate {

  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    return hint && model.canLoadMore && shouldAutoLoad
  }

  func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard shouldAutoLoad else {
      return context.completeBatchFetching(true)
    }

    firstly {
      model.getMessages()

    }.map { (messages: [MessageModel]) -> [IndexPath] in
      var indexes = [IndexPath]()
      let originalCount: Int = self.model.messages.count - messages.count

      for i in 0 ..< messages.count {
        indexes.append(IndexPath(row: i + originalCount, section: 0))
      }

      return indexes

    }.done { (newIndexPaths: [IndexPath]) in
      tableNode.insertRows(at: newIndexPaths, with: .automatic)
      context.completeBatchFetching(newIndexPaths.isNotEmpty)

    }.catch { _ in
      context.completeBatchFetching(true)
      Toast.show("Could not fetch more messages. Will try again.", duration: 2)
    }

  }

}
