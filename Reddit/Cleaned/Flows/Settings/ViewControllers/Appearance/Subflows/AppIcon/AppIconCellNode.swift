//
//  AppIconCellNode.swift
//  Reddit
//
//  Created by made2k on 6/17/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

final class AppIconCellNode: ASCellNode {
  
  private let titleNode = TextNode().then {
    $0.textColor = .label
  }
  
  private let imageNode = ASImageNode().then {
    $0.style.preferredSize = CGSize(square: 50)
    $0.cornerRadius = 13
  }
  
  init(item: AppIconDataItem) {
    
    titleNode.text = item.description
    imageNode.image = item.icon
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    backgroundColor = .systemBackground
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let horizontalSpec = ASStackLayoutSpec.horizontal()
    horizontalSpec.children = [titleNode, ASLayoutSpec.spacer(), imageNode]
    horizontalSpec.verticalAlignment = .center

    let insetSpec = ASInsetLayoutSpec()
    insetSpec.child = horizontalSpec
    insetSpec.insets = UIEdgeInsets(inset: 16)
    
    return insetSpec
  }
  
}
