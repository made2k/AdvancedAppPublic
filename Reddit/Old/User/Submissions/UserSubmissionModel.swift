//
//  UserSubmissionModel.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

class UserSubmissionModel: UserListingModel {
  
  override var requestPath: String {
    return "/user/\(user.name)/submitted"
  }
  
  override func linkWasDeleted(_ linkModel: LinkModel) {
    super.linkWasDeleted(linkModel)
    remove(linkModel)
  }
  
}
