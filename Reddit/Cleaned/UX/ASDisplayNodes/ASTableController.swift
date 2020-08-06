//
//  ASTableController.swift
//  Reddit
//
//  Created by made2k on 7/6/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class ASTableController: ASViewController<ASTableNode> {

  init(style: UITableView.Style) {

    let node = ASTableNode(style: style)
    super.init(node: node)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func hideEmptyCells() {
    node.hideEmptyCells()
  }

}
