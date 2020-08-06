//
//  FlairNode.swift
//  Reddit
//
//  Created by made2k on 7/11/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI

enum FlairType {
  case link
  case comment
}

final class FlairNode: ASDisplayNode {
  
  private let imageNode: FlairImageNode?
  private let textNode: TextNode
  
  init?(flair: Flair, type: FlairType, weight: FontWeight = .regular, size: FontSize = .default, textColor: UIColor = .label) {
    
    // Text Node
    
    textNode = TextNode(weight: weight, size: size, color: textColor)
    textNode.style.flexShrink = 1
    textNode.maximumNumberOfLines = 1
    
    let showImageSetting: Bool
    switch type {
    case .link:
      showImageSetting = Settings.showLinkFlairImages.value

    case .comment:
      showImageSetting = Settings.showCommentFlairImages.value
    }

    if let flairText = flair.text {
      textNode.text = flairText
    }
    
    // Image Node
    
    if flair.images.isNotEmpty && showImageSetting {
      imageNode = FlairImageNode(urls: flair.images, backgroundColor: flair.backgroundColor, backupTintColor: textColor)

    } else {
      imageNode = nil
    }
    
    if imageNode == nil && flair.text.isNilOrEmpty {
      return nil
    }
    
    super.init()
    automaticallyManagesSubnodes = true
    style.flexShrink = 1

    calculateImageSizeIfApplicable()
  }
  
  private func calculateImageSizeIfApplicable() {
    // No image node, no need to calculate size
    guard let imageNode = imageNode else { return }
    
    let calculatedSize = textNode.calculateSizeThatFits(CGSize(square: CGFloat.greatestFiniteMagnitude))
    imageNode.setHeight(calculatedSize.height)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let imageTextSpec = ASStackLayoutSpec.horizontal()
    imageTextSpec.children = []
    if let images = imageNode {
      imageTextSpec.children?.append(images)
    }
    if textNode.text.isNotNilOrEmpty {
      imageTextSpec.children?.append(textNode)
    }
    
    imageTextSpec.verticalAlignment = .center
    imageTextSpec.spacing = 2
    imageTextSpec.style.flexShrink = 1
    
    return imageTextSpec
  }
  
}
