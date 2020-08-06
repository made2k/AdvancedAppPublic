//
//  Subreddit+Additions.swift
//  Reddit
//
//  Created by made2k on 6/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension Subreddit {
  
  static func isUserSubreddit(path: String) -> Bool {
    return UserSubreddit.fromPath(path) != nil
  }

}
