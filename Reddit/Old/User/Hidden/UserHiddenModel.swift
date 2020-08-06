//
//  UserHiddenModel.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import RedditAPI

class UserHiddenModel: UserListingModel {

  override var requestPath: String {
    return "/user/\(user.name)/hidden"
  }

  override init(user: User) {
    super.init(user: user)
    showHiddenPosts = true
  }
  
  override func linkHideStateChanged(_ linkModel: LinkModel) {
    guard linkModel.hidden.value == false else { return }
    remove(linkModel)
  }
}
