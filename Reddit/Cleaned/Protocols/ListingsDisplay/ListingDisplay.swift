//
//  ListingDisplay.swift
//  Reddit
//
//  Created by made2k on 7/5/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

protocol ListingDisplay: ListingsCellDelegate {

  var title: String { get }
  var queryable: String { get }

  var requestPath: String { get }
  var subreddit: Subreddit? { get }
  var over18: Bool { get }

  var showHiddenPosts: Bool { get }
  var previewType: PreviewType { get }

  var listingsDisplayDelegate: ListingDisplayDelegate? { get set }
}
