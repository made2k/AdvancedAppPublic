//
//  CommentCreateCoordinator.swift
//  Reddit
//
//  Created by made2k on 2/4/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import UIKit

final class CommentCreateCoordinator: NSObject, CreationCoordinator {
    
  let model: ReplyCreationModel
  private(set) weak var delegate: CommentCreateCoordinatorDelegate?
    
  // Creation Coordinator Protocol
  let presentingController: UIViewController

  let controllerAutoFill: String?
  var controllerParentHTML: String? { return model.parentHtml }
  var controllerTitle: String { return model.title }
    
  // MARK: - Initialization

  init(presenting: UIViewController,
       replyName: String,
       autofill: String? = nil,
       replyHtml: String? = nil,
       delegate: CommentCreateCoordinatorDelegate?) {
    
    self.model = ReplyCreationModel(parentName: replyName, parentHtml: replyHtml)
    self.delegate = delegate
    
    self.controllerAutoFill = autofill
    self.presentingController = presenting
  }
  
  func autoSave(_ text: String) {
    model.autoSave(text)
  }

  func saveReply(_ text: String) {
    
    Overlay.shared.showProcessingOverlay()

    firstly {
      after(seconds: 0.6)

    }.then { _ -> Promise<Comment> in
      self.model.saveComment(text)

    }.done {
      self.delegate?.addCommentSuccess(comment: $0)

    }.done { _ in
      self.clearAndDismiss()
      Overlay.shared.hideProcessingOverlay()

    }.catch { error in
      log.error("error saving comment", error: error)
      Overlay.shared.flashErrorOverlay(R.string.replyCreate.errorSavingReply())
    }
    
  }
  
}
