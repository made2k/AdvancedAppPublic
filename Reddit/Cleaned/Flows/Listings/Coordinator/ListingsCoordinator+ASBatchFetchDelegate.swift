//
//  ListingsCoordinator+ASBatchFetchDelegate.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ListingsCoordinator: ASBatchFetchingDelegate {

  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    guard let listing = listingDisplay else { return false }
    guard listing.paginator.hasMore else { return false }
    if remainingTime < 1.5 { return true }
    return hint
  }

}
