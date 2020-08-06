//
//  UserUpvotedModel.swift
//  Reddit
//
//  Created by made2k on 4/28/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import UIKit
import RedditAPI

class UserUpvotedModel: UserListingModel {

  override var requestPath: String {
    return "/user/\(user.name)/upvoted"
  }

  override init(user: User) {
    super.init(user: user)
    showHiddenPosts = true
  }

}
