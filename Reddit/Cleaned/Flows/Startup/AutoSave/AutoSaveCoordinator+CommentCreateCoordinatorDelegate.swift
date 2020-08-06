//
//  AutoSaveCoordinator+CommentCreateCoordinatorDelegate.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import PromiseKit
import RedditAPI
import SwiftyJSON

extension AutoSaveCoordinator: CommentCreateCoordinatorDelegate {

  func addCommentSuccess(comment: Comment) {
    showSuccess()
  }

  func editCommentUpdateSuccess(comment: Comment) {
    showSuccess()
  }

  private func showSuccess() {

    firstly {
      after(seconds: 0.75)

    }.done { _ in
      Overlay.shared.flashSuccessOverlay(R.string.autoSave.commentSaved())
    }

  }

}
