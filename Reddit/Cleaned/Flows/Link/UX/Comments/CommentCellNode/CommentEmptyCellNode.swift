//
//  CommentEmptyCellNode.swift
//  Reddit
//
//  Created by made2k on 11/10/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import Then
import UIKit

class CommentEmptyCellNode: ASCellNode {

  private let emptyText = TextNode().then {
    $0.textColor = .label
    $0.text = R.string.link.noCommentsText()
    $0.font = UIFont.boldSystemFont(ofSize: 17)
  }
  
  override init() {
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let textCenter = ASCenterLayoutSpec()
    textCenter.horizontalPosition = .center
    textCenter.verticalPosition = .center
    textCenter.child = emptyText
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    inset.child = textCenter
    
    return inset
  }
}
