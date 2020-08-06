//
//  ActivityIndicatorSelectionCellNode.swift
//  Reddit
//
//  Created by made2k on 6/14/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView

/**
 A cell node that consists of a label with an
 NVActivityIndicator to the right.
 */
class ActivityIndicatorSelectionCellNode: ASCellNode {

  private let textNode = TextNode().then {
    $0.textColor = .label
  }
  let indicator: NVActivityIndicatorNode
  private let disclosureIndicator = ASImageNode().then {
    $0.tintColor = .secondaryLabel
    $0.image = R.image.icon_chevron_right()
    $0.style.preferredSize = CGSize(square: 12)
  }

  init(title: String, activity: NVActivityIndicatorType, backgroundColor: UIColor) {
    textNode.text = title

    indicator = NVActivityIndicatorNode(type: activity).then {
      $0.color = .secondaryLabel
      $0.style.preferredSize = CGSize(square: 24)
    }

    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none

    self.backgroundColor = backgroundColor
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [textNode, ASLayoutSpec.spacer(), indicator, disclosureIndicator]
    horizontalSpec.spacing = 16
    horizontalSpec.verticalAlignment = .center

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(inset: 16)

    return insetSpec
  }

}

