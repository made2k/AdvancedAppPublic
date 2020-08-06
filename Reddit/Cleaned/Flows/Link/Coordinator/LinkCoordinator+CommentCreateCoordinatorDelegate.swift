//
//  LinkCoordinator+CommentCreateCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import RedditAPI
import SwiftyJSON

extension LinkCoordinator: CommentCreateCoordinatorDelegate {

  func addCommentSuccess(comment: Comment) {
    let newComment = CommentModel(comment, parent: nil)

    model?.commentTree?.addComment(commentModel: newComment)
    controller?.reloadSections([1], with: .automatic)
  }
}
