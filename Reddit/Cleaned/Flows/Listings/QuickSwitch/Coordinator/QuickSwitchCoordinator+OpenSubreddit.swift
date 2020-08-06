//
//  QuickSwitchCoordinator+OpenSubreddit.swift
//  Reddit
//
//  Created by made2k on 1/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit

extension QuickSwitchCoordinator {

  func openSubreddit(queryString: String) {
    finish()

    if let model = SubredditCache.shared.lookupModel(queryString) {
      return SplitCoordinator.current.openListing(model)
    }

    Overlay.shared.showProcessingOverlay()
    
    firstly {
      after(seconds: 0.25)

    }.then {
      SubredditModel.verifySubredditExists(path: queryString)

    }.done {
      SplitCoordinator.current.openListing($0)
      Overlay.shared.hideProcessingOverlay()

    }.catch { _ in
      Overlay.shared.flashErrorOverlay("Could not open Subreddit")

    }

  }

  func openSubreddit(subredditName: String) {
    finish()

    if let model = SubredditCache.shared.lookupModel(subredditName) {
      return SplitCoordinator.current.openListing(model)
    }

    SplitCoordinator.current.openSubreddit(subredditName: subredditName)
  }

  func openFeed(model: FeedModel) {
    finish()
    SplitCoordinator.current.openListing(model)
  }

  func openSubreddit(model: SubredditModel) {
    finish()
    SplitCoordinator.current.openListing(model)
  }

}
