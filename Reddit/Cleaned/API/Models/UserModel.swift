//
//  UserModel.swift
//  Reddit
//
//  Created by made2k on 6/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI

class UserModel: ViewModel {
  
  // MARK: - Static Helpers
  
  static func searchUsers(_ query: String) -> Promise<UserModel> {
    return UserCache.shared.loadIfNeeded(query)
  }
  
  // MARK: - Properties

  let user: User
  var username: String { return user.name }

  init(user: User) {
    self.user = user
  }
  
  func loadTrophies() -> Promise<[Trophy]> {
    return api.session.getTrophies(user: user)
  }
  
  func loadKarmaSubreddits() -> Promise<[KarmaListSubreddit]> {
    return api.session.getActiveSubreddits(user: user)
  }
    
}
