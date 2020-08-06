//
//  ListingsCoordinator+ListingsViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 12/29/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import SideMenu
import UIKit

extension ListingsCoordinator: ListingsViewControllerDelegate {

  var sortTiming: TimePeriod {
    return listingDisplay?.sortTiming ?? .all
  }

  func sortButtonPressed() {
    controller?.showSortSelection()
  }

  func settingsButtonPressed() {
    let menu = SideMenuManager.default.rightMenuNavigationController
    guard let sideMenu = menu else { return }
    controller?.present(sideMenu)
  }

  func changedSort(sort: LinkSortType, timing: TimePeriod) {
    listingDisplay?.setSort(type: sort, timing: timing)
  }

  func refresh(with refreshControl: UIRefreshControl?) {
    guard let listing = listingDisplay else {
      refreshControl?.endRefreshing()
      return
    }
    
    firstly {
      listing.reload()

    }.then { _ -> Guarantee<Void> in
      after(seconds: 0.9)
      
    }.catch { _ in
      Toast.show(R.string.listings.failedToLoadPosts())
      
    }.finally {
      refreshControl?.endRefreshing()
    }
    
  }

  func didInitiateQuickSwitch(from navigation: UINavigationController) {
    quickSwitchCoordinator = QuickSwitchCoordinator(presenting: navigation)
    quickSwitchCoordinator?.start()
  }

  func hideReadTemporarily() {
    listingDisplay?.hideReadTemporarily()
  }

  func hideReadPermanently() {
    listingDisplay?.hideReadPermanently()
  }

}

// MARK: - Helper

extension ListingsCoordinator {

  func getDefaultLoader() -> Guarantee<ListingDisplay> {
    return DefaultSubreddits.userDefault().map { $0 as ListingDisplay }
  }

}
