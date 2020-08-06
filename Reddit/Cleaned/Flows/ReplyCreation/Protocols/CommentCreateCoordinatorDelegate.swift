//
//  CommentCreateCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import RedditAPI

protocol CommentCreateCoordinatorDelegate: class {
  func addCommentSuccess(comment: Comment)
}
