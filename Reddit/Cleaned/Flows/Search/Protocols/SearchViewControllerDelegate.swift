//
//  SearchViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 6/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

protocol SearchViewControllerDelegate {

  func didSelectLinkModel(_ model: LinkModel)
  func didSelectUser(_ user: UserModel)
  func didSelectSubreddit(_ result: SubredditSearchResult)

  func didSelectShowAllLinks()

}
