//
//  OpenInTableViewController.swift
//  Reddit
//
//  Created by made2k on 4/24/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

class OpenInTableViewController: ASViewController<ASTableNode> {

  enum Sections: Int, CaseIterable {
    case browser
    case youtube
  }

  let availableBrowsers: [BrowserPreference]
  let availableYouTube: [YouTubePreference]

  override init() {

    availableBrowsers = BrowserPreference.allCases.filter { $0.canOpen }
    availableYouTube = YouTubePreference.allCases.filter { $0.canOpen }

    let node = ASTableNode(style: .grouped)
    node.hideEmptyCells()
    node.backgroundColor = .systemGroupedBackground

    super.init(node: node)

    title = "Open In"

    node.dataSource = self
    node.delegate = self

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
