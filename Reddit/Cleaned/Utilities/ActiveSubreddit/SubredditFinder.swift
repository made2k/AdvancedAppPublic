//
//  SubredditFinder.swift
//  Reddit
//
//  Created by made2k on 2/22/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

class SubredditFinder: NSObject {

  static var activeModel: SubredditModel? {
    return provider?.subredditModel
  }

  static var activeName: String? {
    return provider?.subredditName
  }

  private static var provider: SubredditProvider? {

    let viewControllers = SplitCoordinator.current.visibleViewControllers

    return viewControllers.reversed()
      .map { $0 as? SubredditProvider }
      .compactMap { $0 }
      .first
  }

}
