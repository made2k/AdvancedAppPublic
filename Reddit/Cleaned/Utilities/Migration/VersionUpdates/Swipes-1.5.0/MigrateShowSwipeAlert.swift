//
//  MigrateDiscreteCacheLimits.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import Foundation
import Logging
import PromiseKit

/**
 When upgrading to version 1.5.0 (first version with swipes
 This sets a flag to ask the user if they want to enable swipes or not.
 Should only happen on upgrade and only once.
 */
class MigrateShowSwipeAlert: NSObject, MigrationAction {

  private static let hasAskedForSwipeKey = "f5dbf92e-0dc2-46f7-a634-9b42706c3e4a"

  private static var hasAskedForSwipe: Bool {
    UserDefaults.standard.bool(forKey: hasAskedForSwipeKey)
  }

  static func didCompleteSwipePresentation() {
    UserDefaults.standard.set(true, forKey: hasAskedForSwipeKey)
    shouldShowSwipeAlert = false
  }

  static private(set) var shouldShowSwipeAlert: Bool = false

  func migrate() -> Guarantee<Void> {

    guard MigrateShowSwipeAlert.hasAskedForSwipe == false else { return .value(()) }

    log.info("migration setting value to show swipe alert")
    MigrateShowSwipeAlert.shouldShowSwipeAlert = true

    return .value(())
  }

}
