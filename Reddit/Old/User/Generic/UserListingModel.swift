//
//  UserListingModel.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import PromiseKit
import RxCocoa
import RedditAPI
import UIKit

class UserListingModel: ViewModel, ListingDisplay {
  
  var title: String { return user.name }
  var queryable: String { return title.lowercasedTrim }
  
  var requestPath: String { fatalError("this must be overriden") }
  // TODO: /r/u_username is a valid subreddit
  var subreddit: Subreddit? { return nil }
  var over18: Bool { return false }
  
  var showHiddenPosts = false
  var previewType: PreviewType { return PreviewType.previewType(for: title) }
  
  weak var listingsDisplayDelegate: ListingDisplayDelegate?

  let user: User

  init(user: User) {
    self.user = user
  }
  
  func linkHideStateChanged(_ linkModel: LinkModel) { }
  func linkSaveStateChanged(_ linkModel: LinkModel) { }
  func listingCellToggledSave(for model: LinkModel) -> Promise<Void> {
    return SharedListingsCellDelegate.shared.listingCellToggledSave(for: model)
  }
  func linkWasDeleted(_ linkModel: LinkModel) { }
  
}
