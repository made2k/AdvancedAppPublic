//
//  CommentEditCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

protocol CommentEditCoordinatorDelegate: class {
  func editCommentUpdateSuccess(comment: Comment)
}
