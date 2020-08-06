//
//  LinkViewController+SubredditProvider.swift
//  Reddit
//
//  Created by made2k on 2/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension LinkViewController: SubredditProvider {

  var subredditModel: SubredditModel? {
    guard let name = subredditName else { return nil }
    return SubredditCache.shared.lookupModel(name)
  }

  var subredditName: String? {
    return link?.subreddit
  }

}
