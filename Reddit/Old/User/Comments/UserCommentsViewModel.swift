//
//  UserCommentsViewModel.swift
//  Reddit
//
//  Created by made2k on 6/12/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import RedditAPI

class UserCommentsViewModel: ViewModel {
  var sortType: CommentSort = .new
  var sortTiming: TimePeriod = .all
  

  // MARK: Post Loading
  var comments: [Comment] = []
  var paginator = Paginator.none()
  var path: String {
    return "/user/\(user.name)/comments"
  }
  var canLoadMore: Bool {
    return !comments.isEmpty && paginator.hasMore
  }

  let user: User

  init(user: User) {
    self.user = user
  }
  
  func reset() {
    comments.removeAll()
    paginator = .none()
  }
  
  func loadPosts() -> Promise<[Comment]> {

    return firstly {
      APIContainer.shared.session.loadUserComments(user: user,
                                                   sort: sortType,
                                                   time: sortTiming,
                                                   paginator: paginator)

    }.get {
      self.paginator = $0.paginator
      
    }.map {
      $0.data

    }.get {
      self.comments.append(contentsOf: $0)

    }
  }

}
