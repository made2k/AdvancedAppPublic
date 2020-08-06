//
//  ListingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 1/3/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import PromiseKit
import RedditAPI

protocol ListingsViewControllerDelegate: ASBatchFetchingDelegate, SubredditProvider {

  var sortTiming: TimePeriod { get }

  func refresh(with refreshControl: UIRefreshControl?)

  func sortButtonPressed()
  func settingsButtonPressed()
  
  func hideReadTemporarily()
  func hideReadPermanently()

  func didInitiateQuickSwitch(from navigation: UINavigationController)

  func changedSort(sort: LinkSortType, timing: TimePeriod)
  
  // TODO: This is not very good. It's used for the side menu toggling of preview type
  func togglePreviewTypeForSubreddit()

}
