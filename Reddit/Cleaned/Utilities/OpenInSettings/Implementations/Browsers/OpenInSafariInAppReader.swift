//
//  OpenInSafariInAppReader.swift
//  Reddit
//
//  Created by made2k on 6/20/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import Foundation
import SafariServices

struct OpenInSafariInAppReader: BrowserOpenable {

  static func openUrl(url: URL) {

    let configuration = SFSafariViewController.Configuration()
    configuration.entersReaderIfAvailable = true

    let safariController = RedditSafariViewController(url: url, configuration: configuration)
    SplitCoordinator.current.topViewController.present(safariController)
  }

}
