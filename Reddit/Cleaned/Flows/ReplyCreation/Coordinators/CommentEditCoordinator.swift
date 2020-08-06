//
//  CommentEditCoordinator.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import UIKit

final class CommentEditCoordinator: NSObject, CreationCoordinator {
  
  let model: CommentEditingModel
  weak var delegate: CommentEditCoordinatorDelegate?
  
  // Creation coordinator delegate
  let presentingController: UIViewController
  
  let controllerAutoFill: String?
  let controllerParentHTML: String? = nil
  var controllerTitle: String { return model.title }
    
  // MARK: - Initialization
  
  init(presenting: UIViewController,
       editingComment: CommentModel,
       delegate: CommentEditCoordinatorDelegate) {
    
    self.model = CommentEditingModel(editingModel: editingComment)
    self.controllerAutoFill = editingComment.body
    self.presentingController = presenting
    self.delegate = delegate
  }
  
  func autoSave(_ text: String) { /* There is no autosave for editing */ }
  
  func saveReply(_ text: String) {
    Overlay.shared.showProcessingOverlay()
    
    firstly {
      after(seconds: 0.6)
      
    }.then { _ -> Promise<Comment> in
      self.model.save(text)
      
    }.done {
      self.delegate?.editCommentUpdateSuccess(comment: $0)
      
    }.done { _ in
      self.clearAndDismiss()
      Overlay.shared.hideProcessingOverlay()
      
    }.catch { error in
      log.error("error saving comment edit", error: error)
      Overlay.shared.flashErrorOverlay(R.string.replyCreate.errorEditingComment())
    }
  }
  
}
