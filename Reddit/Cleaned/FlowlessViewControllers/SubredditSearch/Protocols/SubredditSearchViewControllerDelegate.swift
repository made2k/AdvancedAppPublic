//
//  SubredditSearchViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 5/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

protocol SubredditSearchViewControllerDelegate: class {

  func didSelectSearchResult(_ model: SubredditSearchResult)

}
