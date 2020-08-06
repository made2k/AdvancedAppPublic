//
//  AlbumDescriptionCellNode.swift
//  Reddit
//
//  Created by made2k on 2/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit

class AlbumDescriptionCellNode: ASCellNode, UITextViewDelegate {
  
  private let textNode = ASEditableTextNode()
  
  init(description: String) {
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    
    let attributedString = NSAttributedString(
      string: description,
      attributes: [
        NSAttributedString.Key.font: Settings.fontSettings.fontValue
      ])
    
    textNode.attributedText = attributedString
    textNode.scrollEnabled = false
    
    backgroundColor = .secondarySystemGroupedBackground
  }
  
  override func didLoad() {
    super.didLoad()
    
    textNode.textView.isEditable = false
    textNode.textView.delegate = self
    
    textNode.textView.textColor = .label
    textNode.textView.dataDetectorTypes = [.link]
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let insetSpec = ASInsetLayoutSpec()
    insetSpec.insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    insetSpec.child = textNode
    
    return insetSpec
  }
  
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange,
                interaction: UITextItemInteraction) -> Bool {
    
    guard interaction == .invokeDefaultAction else { return true }
    LinkHandler.handleUrl(URL)
    return false
    
  }
  
}
