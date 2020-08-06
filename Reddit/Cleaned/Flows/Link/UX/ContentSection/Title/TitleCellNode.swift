//
//  TitleCellNode.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit
import RedditAPI
import Then

/**
 Displays the Link title, domain, and flair if applicable.
 */
class TitleCellNode: ASCellNode {
  
  /// Separator node used to discern image from title
  private let topSeparator = ColorNode(backgroundColor: .systemBackground).then {
    $0.style.height = ASDimension(unit: .points, value: 1)
  }
  private let titleTextNode = TextNode(weight: .semibold, size: .large)
  private let domainButtonNode = ButtonNode(weight: .light, size: .small, color: .secondaryLabel)
  private let flairTextNode = TextNode(size: .micro, color: .secondaryLabel)
  
  private let model: LinkModel
  
  init(linkModel: LinkModel) {
    self.model = linkModel
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .systemBackground
    
    titleTextNode.text = linkModel.link.title
    
    domainButtonNode.title = linkModel.link.domain
    domainButtonNode.tapAction = {
      guard let url = linkModel.link.url else { return }
      OpenInPreference.shared.openBrowser(url: url)
    }
    
    flairTextNode.text = linkModel.link.flair?.text
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    let verticalSpec = ASStackLayoutSpec.vertical()
    verticalSpec.children = [titleTextNode, domainButtonNode]
    if model.link.flair?.text != nil {
      verticalSpec.children?.append(flairTextNode)
    }
    verticalSpec.spacing = 8
    verticalSpec.alignContent = .start
    verticalSpec.alignItems = .start
    
    let insetSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
      child: verticalSpec)
    
    let separatorVerticalSpec = ASStackLayoutSpec.vertical()
    separatorVerticalSpec.children = [topSeparator, insetSpec]
    
    return separatorVerticalSpec
  }
}
