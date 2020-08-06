//
//  LiveCommentsSettingsViewController.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView

class LiveCommentsSettingsViewController: ASViewController<ASTableNode> {

  private(set) weak var delegate: LiveCommentsSettingsViewControllerDelegate?

  init(delegate: LiveCommentsSettingsViewControllerDelegate) {
    self.delegate = delegate

    let node = ASTableNode(style: .grouped)
    node.backgroundColor = .systemGroupedBackground

    super.init(node: node)

    title = R.string.settings.liveCommentTitle()

    node.dataSource = self
    node.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
