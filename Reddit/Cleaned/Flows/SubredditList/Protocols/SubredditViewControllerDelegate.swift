//
//  SubredditViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/25/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

protocol SubredditViewControllerDelegate: class {

  func didTapListing(_ model: ListingDisplay)
  func didTapSubredditName(_ displayName: String)
  func didTapRandom()

  func didDeleteFeed(_ feed: FeedModel)
  func didDeleteSubscribed(_ subreddit: SubredditModel)

  func didTapToCreateFeed()
  func didTapToEditFeed(_ model: FeedModel)
}
