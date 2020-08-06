//
//  ExpandedPostSearchViewController+ASBatchFetchingDelegate.swift
//  Reddit
//
//  Created by made2k on 7/8/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

extension ExpandedPostSearchViewController: ASBatchFetchingDelegate {

  func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
    guard model.paginator.hasMore else { return false }
    return hint || remainingTime < 1.5
  }

}
