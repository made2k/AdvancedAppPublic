//
//  SubredditListCoordinator+SubredditSearchViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension SubredditListCoordinator: SubredditSearchViewControllerDelegate {

  func didSelectSearchResult(_ result: SubredditSearchResult) {
    openSearchResult(result)
  }

}
