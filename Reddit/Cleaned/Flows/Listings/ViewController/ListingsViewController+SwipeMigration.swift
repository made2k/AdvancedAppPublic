//
//  ListingsViewController+SwipeMigration.swift
//  Reddit
//
//  Created by made2k on 9/24/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import UIKit

extension ListingsViewController {

  func presentSwipeAlertIfNeeded() {

    guard MigrateShowSwipeAlert.shouldShowSwipeAlert else { return }

    let alert = UIAlertController(title: "Update Detected!",
                                  message: "This newest update allows you to swipe on posts, comments, and messages to quickly respond. Would you like to enable this now? You can always change this in Settings -> General",
                                  preferredStyle: .alert)

    alert.addAction(title: "No") { _ in
      MigrateShowSwipeAlert.didCompleteSwipePresentation()
    }

    alert.addAction(title: "Yes") { _ in
      MigrateShowSwipeAlert.didCompleteSwipePresentation()
      Settings.swipeMode.accept(true)
    }

    present(alert)
  }

}
