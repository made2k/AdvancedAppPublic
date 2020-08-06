//
//  AutoSaveCoordinator.swift
//  Reddit
//
//  Created by made2k on 12/28/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import Logging
import PromiseKit
import RedditAPI
import UIKit

class AutoSaveCoordinator: NSObject, Coordinator {

  internal let controller: UIViewController
  private var childCoordinator: Coordinator?

  init(controller: UIViewController) {
    self.controller = controller
  }

  func start() {
    restoreAutoSaveIfNeeded()
  }

  private func restoreAutoSaveIfNeeded() {

    if let reply = AutoSaveManager.shared.getSavedReply() {
      askToRestoreReply(parentName: reply.parentName, text: reply.text, parentText: reply.parentText)

    } else if let submission = AutoSaveManager.shared.getSavedPost() {
      askToRestorePost(autoSave: submission)
    }

  }

  private func askToRestoreReply(parentName: String, text: String, parentText: String?) {
    
    guard let parentType = DataKind.type(from: parentName) else {
      return log.error("unable to get parent type for auto save")
    }
    
    showAutoSaveAlert(title: R.string.autoSave.replyTitle(), message: R.string.autoSave.replyBody()) { [weak self] in
      guard let self = self else { return }
      
      let coordinator: Coordinator
      
      switch parentType {
      case .message:
        coordinator = MessageCreateCoordinator(presenting: self.controller,
                                               replyName: parentName,
                                               autofill: text,
                                               replyHtml: parentText)
      case .comment, .link:
        coordinator = CommentCreateCoordinator(presenting: self.controller,
                                               replyName: parentName,
                                               autofill: text,
                                               replyHtml: parentText,
                                               delegate: self)
      default:
        return
        
      }

      self.childCoordinator = coordinator

      coordinator.start()
    }
  }

  private func askToRestorePost(autoSave: AutoSavedPost) {

    showAutoSaveAlert(title: R.string.autoSave.postTitle(), message: R.string.autoSave.postBody()) { [weak self] in

      attempt(maximumRetryCount: 3, delayBeforeRetry: .seconds(2)) {
        SubredditModel.verifySubredditExists(path: autoSave.subreddit)

      }.done { model in
        
        guard let subreddit = model.subreddit else { return }
        guard let controller = self?.controller else { return }

        SubmissionCoordinator(presenter: controller, subreddit: subreddit, autoSave: autoSave).start()

      }.catch { _ in
        UIPasteboard.general.string = autoSave.text
        let alert = UIAlertController(title: R.string.autoSave.postRestoreErrorTitle(), message: R.string.autoSave.postRestoreErrorBody(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.autoSave.okay(), style: .default, handler: nil))
        self?.controller.present(alert)
      }
    }

  }

  private func showAutoSaveAlert(title: String, message: String, onAgree: @escaping () -> Void) {

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: R.string.autoSave.no(), style: .destructive) { _ in
      AutoSaveManager.shared.clear()
    })

    alert.addAction(UIAlertAction(title: R.string.autoSave.yes(), style: .default) { _ in
      onAgree()
    })

    controller.present(alert)
  }

}
