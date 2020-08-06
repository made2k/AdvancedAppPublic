//
//  LinkCoordinator+LinkViewControllerDelegate.swift
//  Reddit
//
//  Created by made2k on 1/12/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit

extension LinkCoordinator: LinkViewControllerDelegate {

  func clearFocus() -> Promise<Void> {
    focusingId.accept(nil)
    return loadComments()
  }

  @discardableResult
  func loadComments() -> Promise<Void> {

    guard let model = model else {
      log.warn("Attempted to load comments when no model present.")
      return Promise(error: LinkError.noModel)
    }

    return firstly {
      model.refreshCommentTree()

    }.done { _ in
      self.controller?.reloadSections([1], with: .automatic)

    }.recover(on: DispatchQueue.main) { error -> Promise<Void> in
      Toast.show(R.string.link.failedToLoadCommentsMesage(), duration: 3)
      throw error

    }
    
  }

  func viewDidDisappear() {
    // TODO: There seems like there's a better way for this.
    // This is here to prevent the video from pausing when video
    // full screen is entered.
    if controller?.presentedViewController == nil {
      videoDisposable?.disposeVideo()
    }
  }

}
