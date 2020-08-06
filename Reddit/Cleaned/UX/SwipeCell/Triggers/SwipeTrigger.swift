//
//  SwipeTrigger.swift
//  Reddit
//
//  Created by made2k on 9/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Haptica
import RedditAPI

protocol SwipeTrigger {

  var color: UIColor { get }
  var view: SwipeCellTriggerableView { get }
  var mode: SwipeCellNodeMode { get }

  var block: SwipeCellNodeTriggerBlock { get }

}

extension SwipeTrigger {
  
  var isSignedIn: Bool {
    return AccountModel.currentAccount.value.isSignedIn
  }

  // TODO: Test and handle more errors?
  func handleError(_ error: Error) {
    Haptic.notification(.error).generate()

    if case APIError.notSignedIn = error {
      SplitCoordinator.current.splitViewController.showSignInError()
    }
  }
    
  func showArchivedError() {
    Overlay.shared.flashErrorOverlay("Archived")
  }
  
  func showNotSignedInError() {
    SplitCoordinator.current.splitViewController.showSignInError()
  }
  
}
