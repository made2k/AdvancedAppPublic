//
//  LinkEditCoordinator.swift
//  Reddit
//
//  Created by made2k on 8/6/20.
//  Copyright © 2020 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI

final class LinkEditCoordinator: NSObject, CreationCoordinator {

  let model: LinkEditModel
  weak var delegate: LinkEditCoordinatorDelegate?

  // Creation coordinator delegate
  let presentingController: UIViewController

  let controllerAutoFill: String?
  let controllerParentHTML: String? = nil
  let controllerTitle: String = "Edit Link"

  // MARK: - Initialization

  init(
    presenting: UIViewController,
    editingLink: LinkModel,
    delegate: LinkEditCoordinatorDelegate
  ) {

    self.model = LinkEditModel(editingModel: editingLink)
    self.controllerAutoFill = editingLink.selfText.value
    self.presentingController = presenting
    self.delegate = delegate
  }

  func autoSave(_ text: String) { /* There is no autosave for editing */ }

  func saveReply(_ text: String) {
    Overlay.shared.showProcessingOverlay()

    firstly {
      after(seconds: 0.6)

    }.then { _ -> Promise<Link> in
      self.model.save(text)

    }.done {
      self.delegate?.editLinkUpdateSuccess(link: $0)

    }.done { _ in
      self.clearAndDismiss()
      Overlay.shared.hideProcessingOverlay()

    }.catch { error in
      log.error("error saving link edit", error: error)
      Overlay.shared.flashErrorOverlay(R.string.replyCreate.errorEditingComment())
    }
  }

}

