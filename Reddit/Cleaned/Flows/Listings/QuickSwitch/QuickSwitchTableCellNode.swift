//
//  QuickSwitchTableCellNode.swift
//  Reddit
//
//  Created by made2k on 12/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

class QuickSwitchTableCellNode: ASCellNode {

  let textNode = TextNode()

  init(title: String) {
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none

    textNode.text = title

    textNode.textColor = .label
    backgroundColor = .secondarySystemGroupedBackground
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = textNode
    insetSpec.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    return insetSpec
  }

}
