//
//  AlertControllerTableCellNode.swift
//  Reddit
//
//  Created by made2k on 5/29/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

final class AlertControllerTableCellNode: ASCellNode {

  private let action: AlertAction

  private let actionImageNode = ASImageNode().then {
    $0.style.preferredSize = CGSize(square: 25)
    $0.tintColor = .label
    $0.contentMode = .scaleAspectFit
  }
  private let titleNode = TextNode().then {
    $0.textColor = .label
    $0.font = Settings.fontSettings.fontValue
  }
  private let chevronIconNode = ASImageNode().then {
    $0.image = R.image.icon_chevron_right()
    $0.contentMode = .scaleAspectFit
    $0.style.preferredSize = CGSize(square: 18)
    $0.tintColor = .label
  }
  private let separatorNode = ColorNode(backgroundColor: .secondarySystemBackground).then {
    $0.style.height = ASDimension(unit: .points, value: 1)
  }

  private let showSeparator: Bool

  init(_ action: AlertAction, showSeparator: Bool) {
    self.action = action
    self.showSeparator = showSeparator

    self.actionImageNode.image = action.icon
    self.titleNode.text = action.title

    super.init()
    automaticallyManagesSubnodes = true
    selectionStyle = .none
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let horizontalSpacing: CGFloat = 24

    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [actionImageNode, titleNode, ASLayoutSpec.spacer()]
    if action.hasNext { horizontalSpec.children?.append(chevronIconNode) }
    horizontalSpec.verticalAlignment = .center
    horizontalSpec.spacing = 12

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(horizontal: horizontalSpacing, vertical: 24)

    guard showSeparator else { return insetSpec }

    let separatorInsetSpec = ASInsetLayoutSpec()
    separatorInsetSpec.child = separatorNode
    separatorInsetSpec.insets = UIEdgeInsets(horizontal: horizontalSpacing, vertical: 0)

    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [insetSpec, separatorInsetSpec]

    return verticalSpec
  }

}
