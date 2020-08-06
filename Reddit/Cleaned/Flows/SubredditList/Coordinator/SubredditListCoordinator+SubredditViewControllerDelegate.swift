//
//  SubredditListCoordinator+SubredditViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Alamofire
import PromiseKit
import RedditAPI
import SwiftyJSON

extension SubredditListCoordinator: SubredditViewControllerDelegate {

  // MARK: - Opening Models

  func didTapListing(_ model: ListingDisplay) {
    openListing(model)
  }
  
  func didTapSubredditName(_ displayName: String) {
    
    Overlay.shared.showProcessingOverlay()
    
    firstly {
      SubredditModel.verifySubredditExists(path: displayName)
      
    }.done {
      Overlay.shared.hideProcessingOverlay()
      self.openListing($0)
      
    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.subredditList.loadNameError(displayName))
    }
    
  }

  func didTapRandom() {

    Overlay.shared.showProcessingOverlay()

    firstly {
      fetchRandomSubreddit()

    }.done {
      Overlay.shared.hideProcessingOverlay()
      self.openListing($0)

    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.subredditList.loadRandomError())
    }

  }
  
  func openSearchResult(_ result: SubredditSearchResult) {
    // TODO: Pull this out into a better named function
    didTapSubredditName(result.name)
  }
  
  func openListing(_ listing: ListingDisplay) {
    
    if let customAction = customAction {
      customAction(listing)
      
    } else {
      SplitCoordinator.current.openListing(listing)
    }
    
  }

  private func fetchRandomSubreddit() -> Promise<SubredditModel> {
    return firstly {
      APIContainer.shared.session.randomSubreddit()
      
    }.map {
      SubredditModel(subreddit: $0)
    }
  }

  // MARK: - Modifing Models

  func didTapToCreateFeed() {
    let editModel = EditingFeedModel(feedModel: nil)
    let controller = EditMultiViewController(model: editModel, delegate: self)
    
    let navigation = NavigationController(controllers: controller)
    navigation.modalPresentationStyle = .formSheet
    if #available(iOS 13.0, *) {
      navigation.isModalInPresentation = true
    }
    
    self.navigation?.present(navigation)
  }
  
  func didTapToEditFeed(_ model: FeedModel) {
    let editModel = EditingFeedModel(feedModel: model)
    let controller = EditMultiViewController(model: editModel, delegate: self)
    
    let navigation = NavigationController(controllers: controller)
    navigation.modalPresentationStyle = .formSheet
    if #available(iOS 13.0, *) {
      navigation.isModalInPresentation = true
    }
    
    self.navigation?.present(navigation)
  }

  func didDeleteFeed(_ feed: FeedModel) {

    Overlay.shared.showProcessingOverlay()

    firstly {
      after(seconds: 0.25)

    }.then {
      return self.model.deleteFeed(feed)

    }.done {
      Overlay.shared.hideProcessingOverlay()

    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.subredditList.feedDeleteError())
    }

  }

  func didDeleteSubscribed(_ subreddit: SubredditModel) {

    Overlay.shared.showProcessingOverlay()

    firstly {
      model.unsubscribe(subreddit)

    }.done {
      Overlay.shared.hideProcessingOverlay()

    }.catch { _ in
      Overlay.shared.flashErrorOverlay(R.string.subredditList.feedDeleteError())
    }


  }

}
