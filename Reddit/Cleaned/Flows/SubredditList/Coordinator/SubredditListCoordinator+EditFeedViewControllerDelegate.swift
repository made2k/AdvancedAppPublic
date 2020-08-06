//
//  SubredditListCoordinator+EditFeedViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 7/9/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension SubredditListCoordinator: EditFeedViewControllerDelegate {
  
  func didCreateFeed(_ model: FeedModel) {
    self.model.addFeed(model)
  }
  
}
