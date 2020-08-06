//
//  ListingsCoordinator+SubredditProvider.swift
//  Reddit
//
//  Created by made2k on 2/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension ListingsCoordinator: SubredditProvider {

  var subredditModel: SubredditModel? {
    return listingDisplay as? SubredditModel
  }

  var subredditName: String? {
    return subredditModel?.title
  }

}
