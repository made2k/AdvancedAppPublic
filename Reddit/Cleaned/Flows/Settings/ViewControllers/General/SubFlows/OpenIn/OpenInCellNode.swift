//
//  OpenInCellNode.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class OpenInCellNode: ASCellNode {

  private let textNode = TextNode().then {
    $0.textColor = .label
  }
  private let selectionIndicator = ASImageNode().then {
    $0.tintColor = .label
    $0.contentMode = .scaleAspectFit
    $0.style.preferredSize = CGSize(square: 15)
  }

  init(title: String, isSelected: Bool) {
    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none

    backgroundColor = .secondarySystemGroupedBackground

    textNode.text = title
    selectionIndicator.image = R.image.icon_checkmark()
    selectionIndicator.isHidden = isSelected == false
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [textNode, ASLayoutSpec.spacer(), selectionIndicator]
    horizontalSpec.verticalAlignment = .center

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(inset: 16)

    return insetSpec
  }

}
