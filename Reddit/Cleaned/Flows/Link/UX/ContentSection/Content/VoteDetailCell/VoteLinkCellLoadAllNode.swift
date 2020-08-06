//
//  VoteLinkCellLoadAllNode.swift
//  Reddit
//
//  Created by made2k on 1/31/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class VoteLinkCellLoadAllNode: ASControlNode {
  
  private let textNode = TextNode().then {
    $0.textColor = .label
    $0.text = R.string.link.voteCellLoadMore()
  }
  
  override init() {
    super.init()
    
    automaticallyManagesSubnodes = true
    backgroundColor = .secondarySystemBackground
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    return ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8),
      child: textNode)
    
  }
}
