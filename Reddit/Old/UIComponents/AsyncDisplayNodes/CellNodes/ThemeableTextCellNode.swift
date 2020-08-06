//
//  ThemeableTextCellNode.swift
//  Reddit
//
//  Created by made2k on 6/7/18.
//  Copyright © 2018 made2k. All rights reserved.
//

import AsyncDisplayKit

class ThemeableTextCellNode: ASCellNode {
  
  let titleNode = TextNode().then {
    $0.textColor = .label
  }
  let subtitleNode = TextNode().then {
    $0.textColor = .secondaryLabel
  }
  let imageNode = ASImageNode().then {
    $0.tintColor = .label
  }

  var accessoryImage: UIImage? = nil {
    didSet {
      guard let image = accessoryImage else { return }
      if image.renderingMode == .alwaysTemplate {
        imageNode.tintColor = .label

      } else {
        imageNode.tintColor = nil
      }
    }
  }
  
  var cellStyle: UITableViewCell.CellStyle = .default
  
  init(backgroundColor: UIColor) {
    super.init()
    automaticallyManagesSubnodes = true

    self.backgroundColor = backgroundColor

    imageNode.contentMode = .scaleAspectFit
    imageNode.style.preferredSize = CGSize(width: 18, height: 18)

    titleNode.style.flexShrink = 1
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    switch cellStyle {
    case .subtitle:
      return subtitleLayoutSpec()
      
    default:
      return defaultLayoutSpec()
    }
  }
  
  private func defaultLayoutSpec() -> ASLayoutSpec {
    
    let horizontal = ASStackLayoutSpec.horizontal()
    horizontal.children = [titleNode, subtitleNode]
    horizontal.style.flexGrow = 1
    horizontal.style.flexShrink = 1
    horizontal.justifyContent = .spaceBetween
    horizontal.alignItems = .baselineLast
    horizontal.spacing = 12

    let contentSpec: ASLayoutSpec

    if let image = accessoryImage {
      imageNode.image = image
      
      let content = ASStackLayoutSpec.horizontal()
      content.spacing = 8
      content.justifyContent = .start
      content.children = [imageNode, horizontal]
      content.verticalAlignment = .center
      contentSpec = content

    } else {
      contentSpec = horizontal
    }

    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    inset.child = contentSpec
    inset.style.flexShrink = 1
    
    return inset
  }
  
  private func subtitleLayoutSpec() -> ASLayoutSpec {
    
    let vertical = ASStackLayoutSpec.vertical()
    vertical.children = [titleNode, subtitleNode]
    vertical.spacing = 4

    let contentSpec: ASLayoutSpec

    if let image = accessoryImage {
      imageNode.image = image

      let horizontal = ASStackLayoutSpec.horizontal()
      horizontal.spacing = 8
      horizontal.verticalAlignment = .center
      horizontal.children = [imageNode, vertical]
      contentSpec = horizontal

    } else {
      contentSpec = vertical
    }
    
    let inset = ASInsetLayoutSpec()
    inset.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    inset.child = contentSpec
    
    return inset
  }
  
}
