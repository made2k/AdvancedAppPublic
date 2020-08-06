//
//  MessageCreateCoordinator.swift
//  Reddit
//
//  Created by made2k on 9/26/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import UIKit

final class MessageCreateCoordinator: NSObject, CreationCoordinator {
  
  let model: ReplyCreationModel
  
  let presentingController: UIViewController
  
  let controllerAutoFill: String?
  var controllerParentHTML: String? { return model.parentHtml }
  var controllerTitle: String { return model.title }

  init(presenting: UIViewController,
       replyName: String,
       autofill: String? = nil,
       replyHtml: String? = nil) {
    
    self.model = ReplyCreationModel(parentName: replyName, parentHtml: replyHtml)
    
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

    }.then { _ -> Promise<Message> in
      self.model.saveMessage(text)

    }.done { _ in
      self.clearAndDismiss()
      Overlay.shared.hideProcessingOverlay()

    }.catch { error in
      log.error("error saving message", error: error)
      Overlay.shared.flashErrorOverlay(R.string.replyCreate.errorSavingMessage())
    }
  }
  
}
