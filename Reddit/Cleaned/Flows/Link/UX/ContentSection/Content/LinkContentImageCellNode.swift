//
//  ImageCellNode.swift
//  Reddit
//
//  Created by made2k on 10/28/17.
//  Copyright © 2017 made2k. All rights reserved.
//

import AsyncDisplayKit

class LinkContentImageCellNode: ASCellNode {
  
  private let redditNode: RedditMediaNode
  
  var hidingNSFW: Bool {
    get { return redditNode.hidingNSFW }
    set { redditNode.hidingNSFW = newValue }
  }
  
  init(linkModel: LinkModel) {
    redditNode = RedditMediaNode(linkModel: linkModel)
    
    super.init()
    
    automaticallyManagesSubnodes = true
    selectionStyle = .none
    backgroundColor = .systemBackground
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: redditNode)
  }
}
