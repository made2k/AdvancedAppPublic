//
//  ListingsViewController+SubredditProvider.swift
//  Reddit
//
//  Created by made2k on 2/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

extension ListingsViewController: SubredditProvider {

  var subredditModel: SubredditModel? {
    return delegate?.subredditModel
  }

  var subredditName: String? {
    return delegate?.subredditName
  }

}
