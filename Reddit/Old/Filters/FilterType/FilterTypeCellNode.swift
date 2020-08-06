//
//  FilterTypeCellNode.swift
//  Reddit
//
//  Created by made2k on 4/26/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

class FilterTypeCellNode: ASCellNode {
  
  let titleNode = TextNode().then {
    $0.textColor = .label
  }
  let detailNode = TextNode().then {
    $0.textColor = .secondaryLabel
  }
  
  init(type: FilterType) {
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .secondarySystemGroupedBackground
    
    switch type {
    case .post:
      titleNode.text = "Post Filters"
      let count = FilterPreference.shared.postFilters.count
      detailNode.text = "Currently you have \(count) post filter(s)"
    case .comment:
      titleNode.text = "Comment Filters"
      let count = FilterPreference.shared.commentFilters.count
      detailNode.text = "Currently you have \(count) comment filter(s)"
    }
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let stack = ASStackLayoutSpec.vertical()
    stack.children = [titleNode, detailNode]
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    inset.child = stack
    
    return inset
  }

}
