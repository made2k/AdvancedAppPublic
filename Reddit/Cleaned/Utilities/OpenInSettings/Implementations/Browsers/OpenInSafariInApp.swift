//
//  OpenInSafariInApp.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation

struct OpenInSafariInApp: BrowserOpenable {

  static func openUrl(url: URL) {
    let safariController = RedditSafariViewController(url: url)
    SplitCoordinator.current.topViewController.present(safariController)
  }

}
