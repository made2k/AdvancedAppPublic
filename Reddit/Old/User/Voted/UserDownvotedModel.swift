//
//  UserDownvotedModel.swift
//  Reddit
//
//  Created by made2k on 4/28/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import UIKit
import RedditAPI

class UserDownvotedModel: UserListingModel {

  override var requestPath: String {
    return "/user/\(user.name)/downvoted"
  }

  override init(user: User) {
    super.init(user: user)
    showHiddenPosts = true
  }

}
