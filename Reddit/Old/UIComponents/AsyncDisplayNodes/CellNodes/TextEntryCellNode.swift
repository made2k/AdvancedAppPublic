//
//  TextEntryCellNode.swift
//  Reddit
//
//  Created by made2k on 6/7/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextEntryCellNode: ASCellNode {
  
  var titleText: String? {
    didSet {
      titleNode.text = titleText
    }
  }
  
  let titleNode = TextNode().then {
    $0.textColor = .label
  }
  let textNode: ThemeableEditableTextNode

  private let insets: UIEdgeInsets
  
  init(maximumLines: UInt = 0, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), textBackgroundColor: UIColor) {
    self.insets = insets
    self.textNode = ThemeableEditableTextNode(textColor: .label, backgroundColor: textBackgroundColor)

    super.init()
    automaticallyManagesSubnodes = true
    
    textNode.maximumLinesToDisplay = maximumLines
    
    textNode.borderColor = UIColor.secondarySystemBackground.cgColor
    textNode.borderWidth = 1
    textNode.cornerRadius = 5
    textNode.clipsToBounds = true
    
    backgroundColor = .systemBackground
    
    let calculationMin = max(maximumLines, 1)
    let pointSize = textNode.font.pointSize
    let multiplier = textNode.lineHeightMultiple
    let height = pointSize * multiplier * CGFloat(calculationMin) + (16 * multiplier) + 1
    textNode.style.preferredSize = CGSize(width: 0, height: height)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.spacing = 8
    vertical.children = []
    if titleText.isNotNilOrEmpty || titleNode.text.isNotNilOrEmpty {
      vertical.children?.append(titleNode)
    }
    vertical.children?.append(textNode)
        
    let inset = ASInsetLayoutSpec()
    inset.insets = insets
    inset.child = vertical
    
    return inset
  }
}
