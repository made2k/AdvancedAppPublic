//
//  LinkCoordinator+CommentEditCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

extension LinkCoordinator: CommentEditCoordinatorDelegate {
  
  func editCommentUpdateSuccess(comment: Comment) {
    let oldModel = model?.commentTree?
      .allComments
      .first(where: { $0.id == comment.id }) as? CommentModel
    
    oldModel?.copyValues(from: comment)
  }
  
}
