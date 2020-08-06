//
//  HTMLCellNode.swift
//  Reddit
//
//  Created by made2k on 5/20/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class HTMLCellNode: ASCellNode {
  
  let textNode = DTCoreTextNode()
  
  private let onLinkTapped: ((URL) -> Void)?
  private let layoutInsets: UIEdgeInsets
  
  init(html: String?, layoutInsets: UIEdgeInsets, onLinkTapped: ((URL) -> Void)?) {
    self.textNode.html = html
    self.layoutInsets = layoutInsets
    self.onLinkTapped = onLinkTapped
    
    super.init()
    automaticallyManagesSubnodes = true
    
    backgroundColor = .clear
    selectionStyle = .none
    
    textNode.delegate = self
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let inset = ASInsetLayoutSpec()
    inset.insets = layoutInsets
    inset.child = textNode
    
    return inset
  }
  
}

extension HTMLCellNode: ASTextNodeDelegate {
  
  func textNode(_ textNode: ASTextNode,
                shouldHighlightLinkAttribute attribute: String,
                value: Any,
                at point: CGPoint) -> Bool {
    return true
  }
  
  func textNode(_ textNode: ASTextNode,
                tappedLinkAttribute attribute: String,
                value: Any,
                at point: CGPoint,
                textRange: NSRange) {
    
    guard let url = value as? URL else { return }
    onLinkTapped?(url)
  }
  
}
