//
//  LiveCommentsCoordinator+LiveCommentViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 2/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import PromiseKit
import RedditAPI
import RxCocoa
import RxSwift

extension LiveCommentsCoordinator: LiveCommentViewControllerDelegate {

  private struct AssociatedKeys {
    static var idleRelay: UInt8 = 0
  }

  var replyText: Observable<String> {

    return replyingComment
      .map {
        if let author = $0?.author {
          return R.string.liveComments.replyToUser(author)
        } else {
          return R.string.liveComments.replyToPost()
        }
      }

  }

  var idleTimerRelay: BehaviorRelay<Bool> {
    if let relay = objc_getAssociatedObject(self, &AssociatedKeys.idleRelay) as? BehaviorRelay<Bool> {
      return relay
    }

    let relay = BehaviorRelay<Bool>(value: UIApplication.shared.isIdleTimerDisabled)
    objc_setAssociatedObject(self, &AssociatedKeys.idleRelay, relay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    return relay
  }

  var idleButtonTitle: Observable<String> {
    return idleTimerRelay
      .map {
        $0 ?
        R.string.liveComments.idleDisabled() :
        R.string.liveComments.idleEnabled()
      }
  }

  func didReply(with text: String) -> Promise<Void> {
    let parent: Thing = replyingComment.value?.comment ?? model.link
    return sendComment(text: text, parent: parent)
  }

  func didDismiss() {
    // Don't use our binder here since we don't need updates
    UIApplication.shared.isIdleTimerDisabled = false
    model.stopLoading()
    navigation?.dismiss()
  }

  private func sendComment(text: String, parent: Thing) -> Promise<Void> {

    Overlay.shared.showProcessingOverlay(status: "Submitting comment...")

    return firstly {
      model.addComment(text, parent: parent)

    }.done {
      Overlay.shared.hideProcessingOverlay()

    }.recover { error -> Promise<Void> in
      Overlay.shared.flashErrorOverlay("Error Adding Comment")
      throw error
    }
    
  }

}
