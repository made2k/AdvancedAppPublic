//
//  LiveCommentSelectionViewController.swift
//  Reddit
//
//  Created by made2k on 9/1/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView
import UIKit
import Then

class LiveCommentSelectionViewController: ASViewController<ASTableNode> {
  
  let datasource = Array(NVActivityIndicatorType.allCases.suffix(from: 1))

  private(set) weak var delegate: LiveCommentSelectionViewControllerDelegate?

  init(delegate: LiveCommentSelectionViewControllerDelegate) {
    self.delegate = delegate

    let table = ASTableNode(style: .plain)
    table.backgroundColor = .systemBackground
    table.hideEmptyCells()

    super.init(node: table)

    table.dataSource = self
    table.delegate = self

    title = R.string.settings.animationTypeTitle()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
