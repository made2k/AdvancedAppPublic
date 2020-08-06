//
//  DetailLabelCellNode.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class DetailLabelCellNode: ASCellNode {

  let titleNode = TextNode(color: .label)
  let detailNode = TextNode(color: .secondaryLabel)

  init(_ backgroundColor: UIColor) {
    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none

    self.backgroundColor = backgroundColor
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [titleNode, ASLayoutSpec.spacer(), detailNode]
    horizontalSpec.spacing = 4

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(inset: 16)

    return insetSpec

  }

}
