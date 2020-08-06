//
//  FilterCellNode.swift
//  Reddit
//
//  Created by made2k on 4/30/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FilterCellNode: ASCellNode {
  let titleNode = TextNode().then {
    $0.textColor = .label
  }
  
  
  init(filter: Filter) {
    
    titleNode.text = filter.name()
    
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
  }
  
  override func didLoad() {
    super.didLoad()
    view.backgroundColor = .secondarySystemGroupedBackground
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    inset.child = titleNode
    
    return inset
  }

}
