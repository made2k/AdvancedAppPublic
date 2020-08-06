//
//  ListingSearchCoordinator+ASBatchFetchingDelegate.swift
//  Reddit
//
//  Created by made2k on 7/7/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ListingSearchCoordinator: ASBatchFetchingDelegate {

  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    guard model.searchResults.isNotEmpty else { return false }
    guard model.paginator.hasMore else { return false }
    return remainingTime < 1.5 || hint
  }

}
