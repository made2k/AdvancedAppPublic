//
//  BasicCellNode.swift
//  Reddit
//
//  Created by made2k on 11/16/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BasicCellNode: ASCellNode {
  
  let textNode = TextNode()
  
  var text: String? {
    didSet {
      textNode.text = text ?? ""
    }
  }

  init(textColor: UIColor = .label, backgroundColor: UIColor = .systemBackground) {
    textNode.textColor = textColor
    textNode.font = Settings.fontSettings.fontValue
    
    super.init()

    automaticallyManagesSubnodes = true
    selectionStyle = .none
    self.backgroundColor = backgroundColor
    
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    
    inset.child = textNode
    
    return inset    
  }
  
}
